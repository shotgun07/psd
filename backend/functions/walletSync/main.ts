export default async ({ req, res, log, error, sdk }: any) => {
    const { Databases, ID, Query } = sdk;
    const databases = new Databases(sdk);
    const dbId = process.env.DATABASE_ID || 'main_db';
    const usersCollection = process.env.USERS_COLLECTION || 'users';
    const transactionsCollection = process.env.TRANSACTIONS_COLLECTION || 'transactions';
    const locksCollection = process.env.LOCKS_COLLECTION || 'locks';

    try {
        const { user_id, amount, transaction_type, order_id, idempotency_key } = JSON.parse(req.payload);

        // ===== INPUT VALIDATION =====

        // Validate user_id
        if (!user_id || typeof user_id !== 'string' || user_id.length < 10) {
            return res.json({
                success: false,
                error: 'Invalid user_id'
            }, 400);
        }

        // Validate amount (CRITICAL: prevent negative amounts and overflow)
        if (typeof amount !== 'number' || isNaN(amount)) {
            return res.json({
                success: false,
                error: 'Invalid amount: must be a number'
            }, 400);
        }

        // Set reasonable limits (-10000 to +10000 LYD per transaction)
        const MIN_AMOUNT = -10000;
        const MAX_AMOUNT = 10000;

        if (amount < MIN_AMOUNT || amount > MAX_AMOUNT) {
            return res.json({
                success: false,
                error: `Amount out of range (${MIN_AMOUNT} to ${MAX_AMOUNT})`
            }, 400);
        }

        // Validate transaction_type
        const validTypes = ['credit', 'debit', 'refund', 'payment', 'withdrawal', 'deposit'];
        if (!transaction_type || !validTypes.includes(transaction_type)) {
            return res.json({
                success: false,
                error: `Invalid transaction_type. Must be one of: ${validTypes.join(', ')}`
            }, 400);
        }

        // Validate idempotency_key format (if provided)
        if (idempotency_key && (typeof idempotency_key !== 'string' || idempotency_key.length < 10)) {
            return res.json({
                success: false,
                error: 'Invalid idempotency_key format'
            }, 400);
        }

        // ===== IDEMPOTENCY CHECK =====
        const ledgerId = idempotency_key || ID.unique();

        // Check if transaction already exists (prevent double-processing)
        if (idempotency_key) {
            try {
                const existing = await databases.getDocument(dbId, transactionsCollection, ledgerId);
                if (existing) {
                    log(`Idempotent request detected: ${ledgerId}`);
                    return res.json({
                        success: true,
                        message: 'Transaction already processed',
                        transaction_id: ledgerId,
                        idempotent: true
                    });
                }
            } catch (e: any) {
                // Document doesn't exist, proceed with creating it
                if (e.code !== 404) {
                    throw e;
                }
            }
        }

        // ===== CREATE LEDGER ENTRY =====
        const ledgerEntry = await databases.createDocument(dbId, transactionsCollection, ledgerId, {
            user_id,
            amount,
            type: transaction_type,
            order_id: order_id || null,
            status: 'pending',
            created_at: new Date().toISOString(),
        });

        log(`Ledger entry created: ${ledgerEntry.$id}`);

        // ===== OPTIMISTIC LOCKING WITH RETRY =====
        let updated = false;
        let attempts = 0;
        const MAX_ATTEMPTS = 10;
        const lockId = `lock_${user_id}`;
        let newBalance = 0;

        while (!updated && attempts < MAX_ATTEMPTS) {
            try {
                // Acquire lock
                await databases.createDocument(dbId, locksCollection, lockId, {
                    target_id: user_id,
                    locked_at: new Date().toISOString()
                });

                try {
                    // Get current user balance
                    const user = await databases.getDocument(dbId, usersCollection, user_id);
                    const currentBalance = user.wallet_balance || 0;
                    newBalance = currentBalance + amount;

                    // Validate final balance (prevent negative balances for debits)
                    if (newBalance < 0 && !['refund', 'deposit'].includes(transaction_type)) {
                        // Release lock
                        await databases.deleteDocument(dbId, locksCollection, lockId);

                        // Mark transaction as failed
                        await databases.updateDocument(dbId, transactionsCollection, ledgerId, {
                            status: 'failed',
                            error: 'Insufficient balance'
                        });

                        return res.json({
                            success: false,
                            error: 'Insufficient balance',
                            current_balance: currentBalance,
                            attempted_amount: amount
                        }, 400);
                    }

                    // Update user balance
                    await databases.updateDocument(dbId, usersCollection, user_id, {
                        wallet_balance: newBalance,
                        version: (user.version || 0) + 1,
                        updated_at: new Date().toISOString()
                    });

                    updated = true;

                } finally {
                    // Always release lock
                    try {
                        await databases.deleteDocument(dbId, locksCollection, lockId);
                    } catch (unlockError) {
                        // Log but don't fail if unlock fails
                        error(`Failed to release lock ${lockId}: ${unlockError}`);
                    }
                }

            } catch (e: any) {
                attempts++;

                if (attempts >= MAX_ATTEMPTS) {
                    error(`Max lock attempts reached for user ${user_id}`);
                    break;
                }

                // Exponential backoff with jitter
                const delay = Math.pow(2, attempts) * 50 + Math.random() * 50;
                log(`Lock busy for user ${user_id}, retrying in ${delay.toFixed(0)}ms... (${attempts}/${MAX_ATTEMPTS})`);
                await new Promise(resolve => setTimeout(resolve, delay));
            }
        }

        // ===== UPDATE LEDGER STATUS =====
        if (updated) {
            await databases.updateDocument(dbId, transactionsCollection, ledgerId, {
                status: 'completed',
                completed_at: new Date().toISOString()
            });

            return res.json({
                success: true,
                message: 'Wallet synced successfully',
                transaction_id: ledgerId,
                new_balance: newBalance,
                amount_changed: amount
            });
        } else {
            await databases.updateDocument(dbId, transactionsCollection, ledgerId, {
                status: 'failed',
                error: 'Failed to acquire lock after maximum attempts'
            });

            return res.json({
                success: false,
                error: 'Failed to sync wallet after maximum retry attempts'
            }, 500);
        }

    } catch (err: any) {
        error(`Wallet sync error: ${err.message}`);
        return res.json({
            success: false,
            error: 'Internal server error'
        }, 500);
    }
};

/**
 * dailyRecon Function
 * Compares Users' wallet_balance with the sum of their transactions (ledger).
 * Alerts if "State Drift" is detected.
 */
export default async ({ req, res, log, error, sdk }: any) => {
    const { Databases, Query } = sdk;
    const databases = new Databases(sdk);
    const dbId = 'main_db';

    try {
        const users = await databases.listDocuments(dbId, 'users');

        for (const user of users.documents) {
            const txs = await databases.listDocuments(dbId, 'transactions', [
                Query.equal('user_id', user.$id),
                Query.limit(1000)
            ]);

            const expectedBalance = txs.documents.reduce((acc: number, tx: any) => acc + (tx.amount || 0), 0);

            if (Math.abs(user.wallet_balance - expectedBalance) > 0.01) {
                log(`ALERT: State drift detected for user ${user.$id}. DB: ${user.wallet_balance}, Ledger: ${expectedBalance}`);
                // In production, send a Slack/Email notification or trigger a fix
            }
        }

        return res.json({ success: true, processed: users.documents.length });

    } catch (err: any) {
        error(err.message);
        return res.json({ success: false, error: err.message }, 500);
    }
};

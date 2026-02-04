export default async ({ req, res, log, error, sdk }: any) => {
    const { ID, Databases } = sdk;
    const databases = new Databases(sdk);
    const databaseId = process.env.DATABASE_ID || 'main_db';
    const otpCollectionId = process.env.OTP_COLLECTION_ID || 'otp_codes';

    try {
        const { action, phone, otp, user_id } = JSON.parse(req.payload);

        // Validate input
        if (!action || !phone) {
            return res.json({
                success: false,
                error: 'Missing required fields'
            }, 400);
        }

        // Validate phone number format (Libyan format)
        const phoneRegex = /^(\+218|218|0)?9[0-9]{8}$/;
        if (!phoneRegex.test(phone)) {
            return res.json({
                success: false,
                error: 'Invalid phone number format'
            }, 400);
        }

        if (action === 'send') {
            // Check rate limiting: max 3 OTPs per phone per hour
            const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();

            try {
                const recentOtps = await databases.listDocuments(
                    databaseId,
                    otpCollectionId,
                    [
                        `phone.equals("${phone}")`,
                        `created_at.greaterThan("${oneHourAgo}")`
                    ]
                );

                if (recentOtps.total >= 3) {
                    return res.json({
                        success: false,
                        error: 'Too many OTP requests. Please try again later.'
                    }, 429);
                }
            } catch (dbError) {
                // Collection might not exist yet, continue
                log('OTP collection check failed, continuing...');
            }

            // Generate 6-digit OTP
            const generatedOtp = Math.floor(100000 + Math.random() * 900000).toString();
            const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

            // Store OTP in database
            try {
                await databases.createDocument(
                    databaseId,
                    otpCollectionId,
                    ID.unique(),
                    {
                        phone,
                        code: generatedOtp,
                        expires_at: expiresAt.toISOString(),
                        attempts: 0,
                        verified: false,
                        created_at: new Date().toISOString()
                    }
                );
            } catch (dbError: any) {
                error(`Failed to store OTP: ${dbError.message}`);
                // Continue anyway - this is not critical for mock implementation
            }

            log(`[MOCK SMS] To ${phone}: Your OBLNS code is ${generatedOtp}`);

            // IMPORTANT: Only return debug_otp in development
            const isProduction = process.env.ENVIRONMENT === 'production';

            return res.json({
                success: true,
                message: "OTP dispatched",
                ...(!isProduction && { debug_otp: generatedOtp })
            });
        }

        if (action === 'verify') {
            if (!otp) {
                return res.json({
                    success: false,
                    error: 'OTP code is required'
                }, 400);
            }

            // Validate OTP format (6 digits)
            if (!/^[0-9]{6}$/.test(otp)) {
                return res.json({
                    success: false,
                    error: 'Invalid OTP format'
                }, 400);
            }

            // CRITICAL: Remove hardcoded test OTPs in production
            const isProduction = process.env.ENVIRONMENT === 'production';
            if (!isProduction && (otp === '123456' || otp === '999999')) {
                log(`[DEV MODE] Test OTP ${otp} accepted`);
                return res.json({ success: true, message: "Verified (test code)" });
            }

            // Retrieve OTP from database
            try {
                const otpRecords = await databases.listDocuments(
                    databaseId,
                    otpCollectionId,
                    [
                        `phone.equals("${phone}")`,
                        `verified.equals(false)`
                    ]
                );

                if (otpRecords.total === 0) {
                    return res.json({
                        success: false,
                        error: 'OTP not found or already used'
                    }, 404);
                }

                // Get the most recent OTP
                const otpDoc = otpRecords.documents[0];

                // Check if expired
                const expiresAt = new Date(otpDoc.expires_at);
                if (new Date() > expiresAt) {
                    return res.json({
                        success: false,
                        error: 'OTP expired'
                    }, 401);
                }

                // Check attempts
                if (otpDoc.attempts >= 3) {
                    return res.json({
                        success: false,
                        error: 'Too many failed attempts'
                    }, 429);
                }

                // Verify OTP
                if (otpDoc.code !== otp) {
                    // Increment attempts
                    await databases.updateDocument(
                        databaseId,
                        otpCollectionId,
                        otpDoc.$id,
                        { attempts: otpDoc.attempts + 1 }
                    );

                    return res.json({
                        success: false,
                        error: 'Invalid OTP code'
                    }, 401);
                }

                // Mark as verified
                await databases.updateDocument(
                    databaseId,
                    otpCollectionId,
                    otpDoc.$id,
                    {
                        verified: true,
                        verified_at: new Date().toISOString()
                    }
                );

                return res.json({
                    success: true,
                    message: "OTP verified successfully"
                });

            } catch (dbError: any) {
                error(`Database error during verification: ${dbError.message}`);
                return res.json({
                    success: false,
                    error: 'Verification failed'
                }, 500);
            }
        }

        return res.json({
            success: false,
            error: 'Invalid action. Use "send" or "verify"'
        }, 400);

    } catch (err: any) {
        error("OTP Service Error: " + err.message);
        return res.json({
            success: false,
            error: 'Internal server error'
        }, 500);
    }
};

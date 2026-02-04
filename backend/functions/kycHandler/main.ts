export default async ({ req, res, log, error, sdk }: any) => {
    const { Databases } = sdk;
    const db = new Databases(sdk);
    const dbId = 'main_db';
    const usersCollection = 'users';

    try {
        const { user_id } = JSON.parse(req.payload);

        log(`Verifying user ${user_id}...`);

        const isApproved = Math.random() > 0.1;

        await db.updateDocument(dbId, usersCollection, user_id, {
            kyc_status: isApproved ? 'approved' : 'rejected',
            kyc_verified_at: new Date().toISOString()
        });

        return res.json({ success: true, status: isApproved ? 'approved' : 'rejected' });

    } catch (err: any) {
        error(err.message);
        return res.json({ success: false, error: err.message }, 500);
    }
};

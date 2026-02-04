export default async ({ req, res, log, error, sdk }: any) => {
    // Webhook from Sadad/Tadawul
    // Updates transaction status
    const { Databases } = sdk;
    const db = new Databases(sdk);

    try {
        const { order_id, status, payment_id } = req.payload;
        if (status === 'success') {
            // Find transaction by order_id and update
            // ...
            return res.json({ success: true });
        }
        return res.json({ success: true, status: 'ignored' });
    } catch (e: any) {
        return res.json({ success: false }, 500);
    }
};

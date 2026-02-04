/**
 * dispatchEngine V2
 * Advanced matching with scoring and radius expansion.
 */
export default async ({ req, res, log, error, sdk }: any) => {
    const { Databases, Query } = sdk;
    const databases = new Databases(sdk);
    const databaseId = 'main_db';

    try {
        const { order_id } = JSON.parse(req.payload);
        const order = await databases.getDocument(databaseId, 'orders', order_id);

        let R = 2.0; // Initial radius
        const R_max = 10.0;
        const expansion_factor = 1.5;
        let successfulMatch = false;

        while (R <= R_max && !successfulMatch) {
            log(`Dispatch attempt for order ${order_id} with radius ${R}km`);

            const drivers = await databases.listDocuments(databaseId, 'geohash_index', [
                Query.equal('entity_type', 'driver'),
            ]);

            if (drivers.documents.length > 0) {
                const scored = drivers.documents.map((d: any) => {
                    const distance = calculateDistance(order.pickup_lat, order.pickup_lng, d.lat, d.lng);
                    const rating = d.rating || 5.0;
                    const score = (50 / (distance + 1)) + (rating * 10);
                    return { ...d, score };
                }).sort((a: any, b: any) => b.score - a.score);

                for (const candidate of scored.slice(0, 3)) {
                    log(`Attempting to lock driver ${candidate.entity_id}`);
                    await databases.updateDocument(databaseId, 'orders', order_id, {
                        driver_id: candidate.entity_id,
                        status: 'assigned'
                    });
                    successfulMatch = true;
                    break;
                }
            }

            if (!successfulMatch) {
                R *= expansion_factor;
            }
        }

        if (!successfulMatch) {
            return res.json({ success: false, message: 'Escalating to manual dispatch' });
        }

        return res.json({ success: true, status: 'assigned' });

    } catch (err: any) {
        error(err.message);
        return res.json({ success: false, error: err.message }, 500);
    }
};

function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number) {
    const R_EARTH = 6371; // km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLon = (lon2 - lon1) * Math.PI / 180;
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R_EARTH * c;
}

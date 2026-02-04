/**
 * geohashCleanup Function
 * Scheduled job (CRON) to remove stale driver location data and ancient trips for PII protection.
 */
export default async ({ req, res, log, error, sdk }: any) => {
    const { Databases, Query } = sdk;
    const databases = new Databases(sdk);
    const dbId = 'main_db';

    try {
        // 1. Cleanup stale geohash entries (older than 1 hour)
        const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000).toISOString();
        log(`Cleaning up geohash entries older than ${oneHourAgo}`);

        const staleDocs = await databases.listDocuments(dbId, 'geohash_index', [
            Query.lessThan('updated_at', oneHourAgo),
            Query.limit(100)
        ]);

        for (const doc of staleDocs.documents) {
            await databases.deleteDocument(dbId, 'geohash_index', doc.$id);
        }

        log(`Successfully cleaned up ${staleDocs.documents.length} stale geohash entries.`);

        // 2. data retention: Purge ancient trips (PII protection) - older than 90 days
        const ninetyDaysAgo = new Date(Date.now() - 90 * 24 * 60 * 60 * 1000).toISOString();
        const ancientTrips = await databases.listDocuments(dbId, 'trips', [
            Query.lessThan('$createdAt', ninetyDaysAgo),
            Query.limit(100)
        ]);

        for (const trip of ancientTrips.documents) {
            await databases.deleteDocument(dbId, 'trips', trip.$id);
        }

        log(`Purged ${ancientTrips.documents.length} ancient trips.`);

        return res.json({
            success: true,
            geohash_count: staleDocs.documents.length,
            purge_count: ancientTrips.documents.length
        });

    } catch (err: any) {
        error(err.message);
        return res.json({ success: false, error: err.message }, 500);
    }
};

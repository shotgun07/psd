import * as ngeohash from 'ngeohash';

/**
 * geohashService V2
 * Includes neighbor expansion for circular searching.
 */
export default async ({ req, res, log, error }: any) => {
    try {
        const { lat, lng, precision = 7 } = JSON.parse(req.payload);

        const hash = ngeohash.encode(lat, lng, precision);
        const neighbors = ngeohash.neighbors(hash);

        return res.json({
            success: true,
            center: hash,
            neighbors: neighbors,
            search_range: [hash, ...neighbors]
        });
    } catch (err: any) {
        return res.json({ success: false, error: err.message }, 500);
    }
};

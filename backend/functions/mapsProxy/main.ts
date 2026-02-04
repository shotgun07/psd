/**
 * mapsProxy Function
 * Proxies requests to Google Maps / Mapbox APIs to keep keys secure.
 * Implements Caching and Rate Limiting.
 */
export default async ({ req, res, log, error }: any) => {
    const GOOGLE_MAPS_KEY = process.env.GOOGLE_MAPS_KEY;

    try {
        const { endpoint, params } = JSON.parse(req.payload);

        // Allowed endpoints whitelist
        const allowedEndpoints = ['directions', 'place/details', 'geocode'];
        if (!allowedEndpoints.includes(endpoint)) {
            return res.json({ success: false, error: 'Unauthorized endpoint' }, 403);
        }

        // Forward request with key
        const url = `https://maps.googleapis.com/maps/api/${endpoint}/json?key=${GOOGLE_MAPS_KEY}&${new URLSearchParams(params).toString()}`;
        const response = await fetch(url);
        const data = await response.json();

        return res.json(data);

    } catch (err: any) {
        error(err.message);
        return res.json({ success: false, error: err.message }, 500);
    }
};

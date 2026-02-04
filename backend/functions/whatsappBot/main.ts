import { Client, Databases, ID } from 'node-appwrite';

/**
 * WhatsApp Dispatch Bot (Twilio Webhook)
 * Handles incoming messages to order rides via WhatsApp.
 */
export default async ({ req, res, log, error }: any) => {
    const client = new Client()
        .setEndpoint(process.env.APPWRITE_ENDPOINT!)
        .setProject(process.env.APPWRITE_PROJECT_ID!)
        .setKey(process.env.APPWRITE_API_KEY!);

    const databases = new Databases(client);
    const dbId = 'main_db';

    try {
        const params = req.payload; // Twilio sends form-urlencoded usually, check content-type
        // For simplicity assuming JSON or parsed body:
        // Body: { Body: "Location", Latitude: "32.8", Longitude: "13.1", From: "whatsapp:+218..." }

        const from = params.From;
        const msg = params.Body;
        const lat = params.Latitude;
        const lng = params.Longitude;

        if (lat && lng) {
            // Geographic order received
            const order = await databases.createDocument(dbId, 'orders', ID.unique(), {
                type: 'whatsapp_dispatch',
                status: 'pending',
                customer_phone: from.replace('whatsapp:', ''),
                pickup_lat: parseFloat(lat),
                pickup_lng: parseFloat(lng),
                pickup_address: 'WhatsApp Pin', // Should reverse geocode
                platform: 'whatsapp',
                created_at: new Date().toISOString()
            });

            return res.send(`Ride requested! Order ID: ${order.$id}. We are finding a driver.`);
        } else {
            return res.send(`Please send your Live Location to request a ride.`);
        }

    } catch (err: any) {
        error("WhatsApp Bot Error: " + err.message);
        return res.send("Sorry, something went wrong.");
    }
};

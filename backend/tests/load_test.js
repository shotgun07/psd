import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    stages: [
        { duration: '30s', target: 50 }, // Ramp up to 50 users
        { duration: '1m', target: 50 },  // Stay at 50 users
        { duration: '20s', target: 0 },  // Ramp down
    ],
};

export default function () {
    const url = 'http://localhost/v1/functions/priceCalculator/executions';
    const payload = JSON.stringify({
        distance_km: 5.4,
        duration_min: 15,
        vehicle_type: 'car',
    });

    const params = {
        headers: {
            'Content-Type': 'application/json',
            'X-Appwrite-Project': 'oblns-dev',
        },
    };

    const res = http.post(url, payload, params);

    check(res, {
        'status is 200': (r) => r.status === 200,
        'price is present': (r) => r.json().price !== undefined,
    });

    sleep(1);
}

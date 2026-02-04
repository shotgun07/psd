import * as crypto from 'crypto';

/**
 * Signs a payload with HMAC-SHA256
 * @param payload - The data to sign
 * @param timestamp - Unix timestamp in milliseconds
 * @param secret - HMAC secret key
 * @returns Hex-encoded HMAC signature
 */
export const signPayload = (payload: any, timestamp: string, secret: string): string => {
    // Match client implementation: timestamp + JSON.stringify(payload)
    const data = `${timestamp}${JSON.stringify(payload)}`;
    return crypto.createHmac('sha256', secret).update(data).digest('hex');
};

/**
 * Verifies HMAC signature with timing attack protection
 * @param payload - The data that was signed
 * @param timestamp - Unix timestamp from request header
 * @param signature - Signature to verify
 * @param secret - HMAC secret key
 * @returns true if signature is valid
 */
export const verifySignature = (
    payload: any, 
    timestamp: string, 
    signature: string, 
    secret: string
): boolean => {
    try {
        const expected = signPayload(payload, timestamp, secret);
        // Use timing-safe comparison to prevent timing attacks
        return crypto.timingSafeEqual(
            Buffer.from(signature, 'hex'), 
            Buffer.from(expected, 'hex')
        );
    } catch {
        return false;
    }
};

/**
 * Validates request timestamp to prevent replay attacks
 * @param timestamp - Unix timestamp in milliseconds
 * @param maxAgeMs - Maximum age of request in milliseconds (default: 5 minutes)
 * @returns true if timestamp is valid
 */
export const isTimestampValid = (timestamp: string, maxAgeMs: number = 300000): boolean => {
    try {
        const requestTime = parseInt(timestamp, 10);
        if (isNaN(requestTime)) return false;
        
        const now = Date.now();
        const age = Math.abs(now - requestTime);
        
        return age <= maxAgeMs;
    } catch {
        return false;
    }
};

export default async ({ req, res, error, log }: any) => {
    try {
        const { payload, signature } = JSON.parse(req.payload);
        const timestamp = req.headers['x-oblns-timestamp'] || req.headers['X-OBLNS-Timestamp'];
        
        // CRITICAL: No fallback secret - fail if not configured
        const secret = process.env.HMAC_SECRET;
        if (!secret) {
            error('HMAC_SECRET environment variable is not set');
            return res.json({ 
                success: false, 
                error: 'Server configuration error' 
            }, 500);
        }
        
        // Validate timestamp exists
        if (!timestamp) {
            return res.json({ 
                success: false, 
                error: 'Missing timestamp header' 
            }, 401);
        }
        
        // Check if timestamp is recent (prevent replay attacks)
        if (!isTimestampValid(timestamp)) {
            return res.json({ 
                success: false, 
                error: 'Request expired or invalid timestamp' 
            }, 401);
        }
        
        // Verify signature
        const isValid = verifySignature(payload, timestamp, signature, secret);
        
        if (!isValid) {
            log(`HMAC verification failed for timestamp: ${timestamp}`);
            return res.json({ 
                success: false, 
                error: 'Invalid signature' 
            }, 401);
        }
        
        return res.json({ success: true });
        
    } catch (e: any) {
        error(`Security service error: ${e.message}`);
        return res.json({ 
            success: false, 
            error: 'Invalid request format' 
        }, 400);
    }
};

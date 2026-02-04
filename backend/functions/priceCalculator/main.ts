export default async ({ req, res, log, error, sdk }: any) => {
  const { Databases, Query } = sdk;
  const databases = new Databases(sdk);
  const databaseId = process.env.DATABASE_ID || 'main_db';

  try {
    const { distance_km, duration_min, vehicle_type, zone_id } = JSON.parse(req.payload);

    // ===== INPUT VALIDATION =====

    // Validate distance_km
    if (typeof distance_km !== 'number' || isNaN(distance_km) || distance_km < 0) {
      return res.json({
        success: false,
        error: 'Invalid distance: must be a positive number'
      }, 400);
    }

    if (distance_km > 1000) {
      return res.json({
        success: false,
        error: 'Distance exceeds maximum allowed (1000 km)'
      }, 400);
    }

    // Validate duration_min
    if (typeof duration_min !== 'number' || isNaN(duration_min) || duration_min < 0) {
      return res.json({
        success: false,
        error: 'Invalid duration: must be a positive number'
      }, 400);
    }

    if (duration_min > 1440) { // 24 hours
      return res.json({
        success: false,
        error: 'Duration exceeds maximum allowed (1440 minutes)'
      }, 400);
    }

    // Validate vehicle_type
    const validVehicleTypes = ['bike', 'car', 'van', 'truck'];
    if (!vehicle_type || !validVehicleTypes.includes(vehicle_type)) {
      return res.json({
        success: false,
        error: `Invalid vehicle_type. Must be one of: ${validVehicleTypes.join(', ')}`
      }, 400);
    }

    // Validate zone_id (optional)
    if (zone_id && (typeof zone_id !== 'string' || zone_id.length > 50)) {
      return res.json({
        success: false,
        error: 'Invalid zone_id format'
      }, 400);
    }

    // ===== PRICE CALCULATION =====

    const baseRates = {
      'bike': { base: 2.0, per_km: 0.5, per_min: 0.1 },
      'car': { base: 5.0, per_km: 1.2, per_min: 0.2 },
      'van': { base: 8.0, per_km: 1.5, per_min: 0.25 },
      'truck': { base: 12.0, per_km: 2.0, per_min: 0.3 },
    };

    const rates = baseRates[vehicle_type];

    // ===== SURGE PRICING (Dynamic) =====
    let surgeMultiplier = 1.0;

    try {
      const lastSurgeDoc = await databases.listDocuments(databaseId, 'metadata', [
        Query.equal('key', `surge_${zone_id || 'default'}`),
        Query.limit(1)
      ]);

      const lastSurge = lastSurgeDoc.documents[0]?.value || 1.0;

      // Get real demand from active orders (better than Math.random())
      let currentDemand = 1.0;
      try {
        const activeOrders = await databases.listDocuments(databaseId, 'orders', [
          Query.equal('status', 'pending'),
          Query.equal('zone_id', zone_id || 'default'),
          Query.limit(100)
        ]);

        // Calculate demand based on active orders
        const orderCount = Math.min(activeOrders.total, 100);
        currentDemand = 1.0 + (orderCount / 25); // Increase by 1 for every 25 orders

      } catch (demandError) {
        log('Could not fetch active orders for demand calculation, using default');
      }

      // Exponentially Weighted Moving Average (EWMA)
      const alpha = 0.3;
      surgeMultiplier = (alpha * currentDemand) + (1 - alpha) * lastSurge;

      // Clamp surge multiplier between 1.0 and 3.5
      surgeMultiplier = Math.max(1.0, Math.min(surgeMultiplier, 3.5));

      // Update surge value in database for next calculation
      try {
        if (lastSurgeDoc.total > 0) {
          await databases.updateDocument(
            databaseId,
            'metadata',
            lastSurgeDoc.documents[0].$id,
            {
              value: surgeMultiplier,
              updated_at: new Date().toISOString()
            }
          );
        } else {
          await databases.createDocument(
            databaseId,
            'metadata',
            'unique()',
            {
              key: `surge_${zone_id || 'default'}`,
              value: surgeMultiplier,
              created_at: new Date().toISOString()
            }
          );
        }
      } catch (updateError) {
        // Non-critical, log and continue
        log(`Failed to update surge value: ${updateError}`);
      }

    } catch (e) {
      log("Surge calculation error, using default multiplier: 1.0");
      surgeMultiplier = 1.0;
    }

    // ===== FINAL PRICE CALCULATION =====
    const distanceCost = distance_km * rates.per_km;
    const durationCost = duration_min * rates.per_min;
    const subtotal = rates.base + distanceCost + durationCost;
    const price = subtotal * surgeMultiplier;

    // Round to 2 decimal places
    const finalPrice = Math.round(price * 100) / 100;
    const roundedSurge = Math.round(surgeMultiplier * 100) / 100;

    return res.json({
      success: true,
      price: finalPrice,
      currency: 'LYD',
      surge_multiplier: roundedSurge,
      breakdown: {
        base_fare: rates.base,
        distance_cost: Math.round(distanceCost * 100) / 100,
        duration_cost: Math.round(durationCost * 100) / 100,
        subtotal: Math.round(subtotal * 100) / 100,
        surge_applied: roundedSurge > 1.0,
        distance_km,
        duration_min,
        vehicle_type
      }
    });

  } catch (err: any) {
    error(`Price calculator error: ${err.message}`);
    return res.json({
      success: false,
      error: 'Internal server error'
    }, 500);
  }
};

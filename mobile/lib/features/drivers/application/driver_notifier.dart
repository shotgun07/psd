import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/models/trip_model.dart';
import 'package:oblns/features/drivers/domain/driver_repository.dart';
import 'package:oblns/core/utils/error_messages.dart';
import 'package:oblns/core/observability/logging_config.dart';
import 'package:oblns/features/drivers/infrastructure/appwrite_driver_repository.dart';

/// حالات السائق - Driver States
enum DriverStatus {
  initial,
  offline,
  online,
  busy, // في رحلة
  error,
}

/// حالة السائق - Driver State
class DriverState {
  final DriverStatus status;
  final bool isOnline;
  final TripModel? currentTrip;
  final Map<String, dynamic>? pendingOrder; // الطلب المعلق
  final List<Map<String, dynamic>> nearbyOrders;
  final String? errorMessage;
  final double todayEarnings;
  final int tripsCompleted;

  const DriverState({
    required this.status,
    this.isOnline = false,
    this.currentTrip,
    this.pendingOrder,
    this.nearbyOrders = const [],
    this.errorMessage,
    this.todayEarnings = 0.0,
    this.tripsCompleted = 0,
  });

  factory DriverState.initial() =>
      const DriverState(status: DriverStatus.initial);

  DriverState copyWith({
    DriverStatus? status,
    bool? isOnline,
    TripModel? currentTrip,
    Map<String, dynamic>? pendingOrder,
    List<Map<String, dynamic>>? nearbyOrders,
    String? errorMessage,
    double? todayEarnings,
    int? tripsCompleted,
  }) {
    return DriverState(
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      currentTrip: currentTrip ?? this.currentTrip,
      pendingOrder: pendingOrder,
      nearbyOrders: nearbyOrders ?? this.nearbyOrders,
      errorMessage: errorMessage,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      tripsCompleted: tripsCompleted ?? this.tripsCompleted,
    );
  }

  bool get hasPendingOrder => pendingOrder != null;
  bool get hasActiveTrip => currentTrip != null;
}

/// مدير حالة السائق - Driver State Manager
class DriverNotifier extends Notifier<DriverState> {
  @override
  DriverState build() => DriverState.initial();

  DriverRepository get _repository => ref.watch(driverRepositoryProvider);

  /// تعيين حالة الانترنت (متصل/غير متصل) - Set online/offline status
  Future<bool> setOnlineStatus(bool isOnline) async {
    try {
      AppLogger.info('Setting driver status', {'isOnline': isOnline});

      await _repository.setStatus(isOnline ? 'active' : 'inactive');

      state = state.copyWith(
        status: isOnline ? DriverStatus.online : DriverStatus.offline,
        isOnline: isOnline,
      );

      AppLogger.security('Driver status changed', {
        'status': isOnline ? 'online' : 'offline',
      });

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set driver status', e, stackTrace);
      state = state.copyWith(
        status: DriverStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
      return false;
    }
  }

  /// قبول طلب - Accept order
  Future<bool> acceptOrder(String orderId) async {
    if (state.currentTrip != null) {
      state = state.copyWith(
        status: DriverStatus.error,
        errorMessage: 'لديك رحلة نشطة بالفعل',
      );
      return false;
    }

    try {
      AppLogger.info('Accepting order', {'order_id': orderId});

      await _repository.acceptOrder(orderId);

      state = state.copyWith(status: DriverStatus.busy, pendingOrder: null);

      AppLogger.analytics('order_accepted', {'order_id': orderId});

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to accept order', e, stackTrace);
      state = state.copyWith(
        status: DriverStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
      return false;
    }
  }

  /// رفض طلب - Reject order
  Future<bool> rejectOrder(String orderId, {String? reason}) async {
    try {
      AppLogger.info('Rejecting order', {
        'order_id': orderId,
        'reason': reason,
      });

      // Note: This requires implementing rejectOrder in DriverRepository
      // await _repository.rejectOrder(orderId, reason: reason);

      state = state.copyWith(pendingOrder: null, status: DriverStatus.online);

      AppLogger.analytics('order_rejected', {
        'order_id': orderId,
        'reason': reason,
      });

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to reject order', e, stackTrace);
      state = state.copyWith(
        status: DriverStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
      return false;
    }
  }

  /// إكمال الرحلة - Complete trip
  Future<bool> completeTrip(String tripId) async {
    if (state.currentTrip == null) {
      state = state.copyWith(
        status: DriverStatus.error,
        errorMessage: 'لا توجد رحلة نشطة',
      );
      return false;
    }

    try {
      AppLogger.info('Completing trip', {'trip_id': tripId});

      // Note: This requires implementing completeTrip in DriverRepository
      // await _repository.completeTrip(tripId);

      final tripEarnings = state.currentTrip?.fare ?? 0.0;

      state = state.copyWith(
        status: DriverStatus.online,
        currentTrip: null,
        todayEarnings: state.todayEarnings + tripEarnings,
        tripsCompleted: state.tripsCompleted + 1,
      );

      AppLogger.financial('Trip completed', tripEarnings, 'LYD', {
        'trip_id': tripId,
        'today_earnings': state.todayEarnings,
        'trips_count': state.tripsCompleted,
      });

      AppLogger.analytics('trip_completed_by_driver', {
        'trip_id': tripId,
        'earnings': tripEarnings,
      });

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to complete trip', e, stackTrace);
      state = state.copyWith(
        status: DriverStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
      return false;
    }
  }

  /// بدء الرحلة - Start trip (after arriving at pickup)
  Future<bool> startTrip(String tripId) async {
    if (state.currentTrip == null) {
      state = state.copyWith(
        status: DriverStatus.error,
        errorMessage: 'لا توجد رحلة نشطة',
      );
      return false;
    }

    try {
      AppLogger.info('Starting trip', {'trip_id': tripId});

      // Note: This requires implementing startTrip in DriverRepository
      // await _repository.startTrip(tripId);

      AppLogger.analytics('trip_started', {'trip_id': tripId});

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to start trip', e, stackTrace);
      state = state.copyWith(
        status: DriverStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
      return false;
    }
  }

  /// الوصول إلى نقطة الالتقاط - Arrive at pickup
  Future<bool> arriveAtPickup(String tripId) async {
    try {
      AppLogger.info('Arrived at pickup', {'trip_id': tripId});

      // Note: This requires implementing arriveAtPickup in DriverRepository
      // await _repository.arriveAtPickup(tripId);

      AppLogger.analytics('arrived_at_pickup', {'trip_id': tripId});

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to mark arrival at pickup', e, stackTrace);
      state = state.copyWith(
        status: DriverStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
      return false;
    }
  }

  /// تحديث الطلب المعلق - Update pending order
  void updatePendingOrder(Map<String, dynamic>? order) {
    state = state.copyWith(pendingOrder: order);
    if (order != null) {
      AppLogger.info('New pending order', {'order_id': order['id']});
    }
  }

  /// تحديث الطلبات القريبة - Update nearby orders
  void updateNearbyOrders(List<Map<String, dynamic>> orders) {
    state = state.copyWith(nearbyOrders: orders);
    AppLogger.debug('Nearby orders updated', {'count': orders.length});
  }

  /// تحديث الرحلة الحالية - Update current trip
  void updateCurrentTrip(TripModel trip) {
    state = state.copyWith(currentTrip: trip);
  }

  /// تحميل أرباح اليوم - Load today's earnings
  Future<void> loadTodayEarnings() async {
    try {
      AppLogger.info('Loading today earnings');

      // Note: This requires implementing getTodayEarnings in DriverRepository
      // final earnings = await _repository.getTodayEarnings();
      // final tripsCount = await _repository.getTodayTripsCount();

      state = state.copyWith(
        // todayEarnings: earnings,
        // tripsCompleted: tripsCount,
      );

      AppLogger.info('Today earnings loaded', {
        'earnings': state.todayEarnings,
        'trips': state.tripsCompleted,
      });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load today earnings', e, stackTrace);
    }
  }

  /// مسح الخطأ - Clear error
  void clearError() {
    if (state.status == DriverStatus.error) {
      state = state.copyWith(
        status: state.isOnline ? DriverStatus.online : DriverStatus.offline,
        errorMessage: null,
      );
    }
  }

  /// إعادة تعيين الحالة - Reset state
  void reset() {
    state = DriverState.initial();
  }
}

/// مزود حالة السائق - Driver State Provider
final driverProvider = NotifierProvider<DriverNotifier, DriverState>(() {
  return DriverNotifier();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oblns/core/models/trip_model.dart';
import 'package:oblns/features/orders/domain/order_repository.dart';
import 'package:oblns/core/utils/error_messages.dart';
import 'package:oblns/core/observability/logging_config.dart';
import 'package:oblns/core/providers/app_providers.dart';

/// حالات الطلب - Order States
enum OrderStatus {
  initial,
  creating,
  searching, // البحث عن سائق
  assigned, // تم تعيين سائق
  tracking, // تتبع الرحلة
  completed,
  cancelled,
  error,
}

/// نموذج طلب الركوب - Ride Request Model
class OrderRequest {
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double destinationLat;
  final double destinationLng;
  final String destinationAddress;
  final String? notes;
  final String? guardianId; // معرف الوصي للأمان العائلي

  const OrderRequest({
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.destinationLat,
    required this.destinationLng,
    required this.destinationAddress,
    this.notes,
    this.guardianId,
  });

  Map<String, dynamic> toJson() => {
    'pickup_lat': pickupLat,
    'pickup_lng': pickupLng,
    'pickup_address': pickupAddress,
    'destination_lat': destinationLat,
    'destination_lng': destinationLng,
    'destination_address': destinationAddress,
    'notes': notes,
    'guardian_id': guardianId,
  };
}

/// حالة الطلب - Order State
class OrderState {
  final OrderStatus status;
  final TripModel? currentTrip;
  final List<TripModel> tripHistory;
  final String? errorMessage;
  final double? estimatedPrice;
  final String? assignedDriverId;

  const OrderState({
    required this.status,
    this.currentTrip,
    this.tripHistory = const [],
    this.errorMessage,
    this.estimatedPrice,
    this.assignedDriverId,
  });

  factory OrderState.initial() => const OrderState(status: OrderStatus.initial);

  OrderState copyWith({
    OrderStatus? status,
    TripModel? currentTrip,
    List<TripModel>? tripHistory,
    String? errorMessage,
    double? estimatedPrice,
    String? assignedDriverId,
  }) {
    return OrderState(
      status: status ?? this.status,
      currentTrip: currentTrip ?? this.currentTrip,
      tripHistory: tripHistory ?? this.tripHistory,
      errorMessage: errorMessage,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
    );
  }

  bool get hasActiveTrip =>
      currentTrip != null &&
      (status == OrderStatus.searching ||
          status == OrderStatus.assigned ||
          status == OrderStatus.tracking);
}

/// مدير حالة الطلبات - Order State Manager
class OrderNotifier extends Notifier<OrderState> {
  @override
  OrderState build() => OrderState.initial();

  OrderRepository get _repository => ref.watch(orderRepositoryProvider);

  /// إنشاء طلب جديد - Create new order
  Future<bool> createOrder(OrderRequest request) async {
    state = state.copyWith(status: OrderStatus.creating);

    try {
      AppLogger.info('Creating new order', request.toJson());

      // Call repository to create order in Appwrite
      final orderId = await _repository.createOrder(
        type: 'ride',
        pickupLat: request.pickupLat,
        pickupLng: request.pickupLng,
        pickupAddress: request.pickupAddress,
        dropoffLat: request.destinationLat,
        dropoffLng: request.destinationLng,
        dropoffAddress: request.destinationAddress,
        totalPrice: state.estimatedPrice ?? 0.0,
        paymentMethod: 'cash',
      );

      // Start tracking the order immediately
      await trackOrder(orderId);

      state = state.copyWith(status: OrderStatus.searching);

      AppLogger.info('Order created successfully', {
        'order_id': orderId,
        'pickup': request.pickupAddress,
        'destination': request.destinationAddress,
      });

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to create order', e, stackTrace);
      state = state.copyWith(
        status: OrderStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
      return false;
    }
  }

  /// تتبع الطلب - Track order
  Future<void> trackOrder(String orderId) async {
    state = state.copyWith(status: OrderStatus.tracking);

    try {
      AppLogger.info('Tracking order', {'order_id': orderId});

      final tripStream = _repository.watchOrder(orderId);
      tripStream.listen(
        (trip) {
          OrderStatus newStatus = OrderStatus.tracking;
          if (trip.status == 'assigned') newStatus = OrderStatus.assigned;
          if (trip.status == 'completed') newStatus = OrderStatus.completed;

          state = state.copyWith(status: newStatus, currentTrip: trip);
        },
        onError: (e, st) {
          AppLogger.error('Trip stream error', e, st);
          state = state.copyWith(
            status: OrderStatus.error,
            errorMessage: ErrorMessages.getArabicMessage(e),
          );
        },
      );

      state = state.copyWith(status: OrderStatus.tracking);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to track order', e, stackTrace);
      state = state.copyWith(
        status: OrderStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
    }
  }

  /// إلغاء الطلب - Cancel order
  Future<bool> cancelOrder(String orderId, {String? reason}) async {
    try {
      AppLogger.info('Cancelling order', {
        'order_id': orderId,
        'reason': reason,
      });

      await _repository.cancelOrder(orderId);

      state = state.copyWith(status: OrderStatus.cancelled, currentTrip: null);

      AppLogger.info('Order cancelled successfully', {'order_id': orderId});

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to cancel order', e, stackTrace);
      state = state.copyWith(
        status: OrderStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
      return false;
    }
  }

  /// تقييم الرحلة - Rate trip
  Future<bool> rateTrip(String orderId, int rating, String? comment) async {
    if (rating < 1 || rating > 5) {
      state = state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'التقييم يجب أن يكون بين 1 و 5',
      );
      return false;
    }

    try {
      AppLogger.info('Rating trip', {
        'order_id': orderId,
        'rating': rating,
        'comment': comment,
      });

      // Call repository to persist rating
      await _repository.rateTrip(orderId, rating, comment);

      // Update local state: mark trip completed
      state = state.copyWith(
        status: OrderStatus.completed,
        currentTrip: state.currentTrip,
      );

      AppLogger.analytics('trip_rated', {
        'order_id': orderId,
        'rating': rating,
      });

      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to rate trip', e, stackTrace);
      state = state.copyWith(
        status: OrderStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
      return false;
    }
  }

  /// تحميل سجل الرحلات - Load trip history
  Future<void> loadTripHistory() async {
    try {
      AppLogger.info('Loading trip history');

      // Note: This requires implementing getTripHistory in OrderRepository
      // final trips = await _repository.getTripHistory();

      state = state.copyWith(
        // tripHistory: trips,
      );

      AppLogger.info('Trip history loaded', {
        'count': state.tripHistory.length,
      });
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load trip history', e, stackTrace);
      state = state.copyWith(
        status: OrderStatus.error,
        errorMessage: ErrorMessages.getArabicMessage(e),
      );
    }
  }

  /// تحديث معلومات الرحلة الحالية - Update current trip info
  void updateCurrentTrip(TripModel trip) {
    state = state.copyWith(currentTrip: trip);
  }

  /// تعيين سائق للطلب - Assign driver to order
  void assignDriver(String driverId) {
    state = state.copyWith(
      status: OrderStatus.assigned,
      assignedDriverId: driverId,
    );
    AppLogger.info('Driver assigned', {'driver_id': driverId});
  }

  /// إكمال الرحلة - Complete trip
  Future<void> completeTrip() async {
    if (state.currentTrip == null) {
      state = state.copyWith(
        status: OrderStatus.error,
        errorMessage: 'لا توجد رحلة نشطة',
      );
      return;
    }

    state = state.copyWith(status: OrderStatus.completed);

    AppLogger.analytics('trip_completed', {
      'trip_id': state.currentTrip!.id,
      'fare': state.currentTrip!.fare,
    });
  }

  /// حساب السعر التقديري - Calculate estimated price
  Future<void> calculateEstimatedPrice(
    double pickupLat,
    double pickupLng,
    double destLat,
    double destLng,
  ) async {
    try {
      AppLogger.info('Calculating estimated price');

      // Note: This should call the priceCalculator function
      // final price = await _repository.getEstimatedPrice(...);

      state = state.copyWith(
        // estimatedPrice: price,
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to calculate price', e, stackTrace);
      state = state.copyWith(errorMessage: ErrorMessages.getArabicMessage(e));
    }
  }

  /// مسح الخطأ - Clear error
  void clearError() {
    if (state.status == OrderStatus.error) {
      state = state.copyWith(
        status: state.currentTrip != null
            ? OrderStatus.tracking
            : OrderStatus.initial,
        errorMessage: null,
      );
    }
  }

  /// إعادة تعيين الحالة - Reset state
  void reset() {
    state = OrderState.initial();
  }
}

/// مزود حالة الطلبات - Order State Provider
final orderProvider = NotifierProvider<OrderNotifier, OrderState>(() {
  return OrderNotifier();
});

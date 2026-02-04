import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_model.freezed.dart'; 
part 'driver_model.g.dart';

@freezed
abstract class DriverModel with _$DriverModel {
  const DriverModel._();

  const factory DriverModel({
    required String id,
    required String userId,
    @Default(false) bool isOnline,
    double? currentLat,
    double? currentLng,
    @Default(5.0) double rating,
    String? vehicleType,
    String? vehiclePlate,
    String? vehicleDetails,
    @Default('pending') String verificationStatus,
  }) = _DriverModel;

  factory DriverModel.fromJson(Map<String, dynamic> json) =>
      _$DriverModelFromJson(json);
}

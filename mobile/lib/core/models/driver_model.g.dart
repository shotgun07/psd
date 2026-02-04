// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverModel _$DriverModelFromJson(Map<String, dynamic> json) => _DriverModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  isOnline: json['isOnline'] as bool? ?? false,
  currentLat: (json['currentLat'] as num?)?.toDouble(),
  currentLng: (json['currentLng'] as num?)?.toDouble(),
  rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
  vehicleType: json['vehicleType'] as String?,
  vehiclePlate: json['vehiclePlate'] as String?,
  vehicleDetails: json['vehicleDetails'] as String?,
  verificationStatus: json['verificationStatus'] as String? ?? 'pending',
);

Map<String, dynamic> _$DriverModelToJson(_DriverModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'isOnline': instance.isOnline,
      'currentLat': instance.currentLat,
      'currentLng': instance.currentLng,
      'rating': instance.rating,
      'vehicleType': instance.vehicleType,
      'vehiclePlate': instance.vehiclePlate,
      'vehicleDetails': instance.vehicleDetails,
      'verificationStatus': instance.verificationStatus,
    };

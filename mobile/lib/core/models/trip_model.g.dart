// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TripModel _$TripModelFromJson(Map<String, dynamic> json) => _TripModel(
  id: json['id'] as String,
  riderId: json['rider_id'] as String,
  driverId: json['driver_id'] as String?,
  status: json['status'] as String,
  originLat: (json['pickup_lat'] as num).toDouble(),
  originLng: (json['pickup_lng'] as num).toDouble(),
  destLat: (json['dest_lat'] as num).toDouble(),
  destLng: (json['dest_lng'] as num).toDouble(),
  fare: (json['fare'] as num?)?.toDouble(),
  geohash: json['geohash'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TripModelToJson(_TripModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rider_id': instance.riderId,
      'driver_id': instance.driverId,
      'status': instance.status,
      'pickup_lat': instance.originLat,
      'pickup_lng': instance.originLng,
      'dest_lat': instance.destLat,
      'dest_lng': instance.destLng,
      'fare': instance.fare,
      'geohash': instance.geohash,
      'created_at': instance.createdAt?.toIso8601String(),
    };

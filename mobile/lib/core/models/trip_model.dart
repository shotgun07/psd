import 'package:freezed_annotation/freezed_annotation.dart';

part 'trip_model.freezed.dart';
part 'trip_model.g.dart';

@freezed
abstract class TripModel with _$TripModel {
  const TripModel._();

  const factory TripModel({
    required String id,
    @JsonKey(name: 'rider_id') required String riderId,
    @JsonKey(name: 'driver_id') String? driverId,
    required String status,
    @JsonKey(name: 'pickup_lat') required double originLat,
    @JsonKey(name: 'pickup_lng') required double originLng,
    @JsonKey(name: 'dest_lat') required double destLat,
    @JsonKey(name: 'dest_lng') required double destLng,
    double? fare,
    String? geohash,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _TripModel;

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);
}

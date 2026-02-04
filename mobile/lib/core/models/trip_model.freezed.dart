// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TripModel {

 String get id;@JsonKey(name: 'rider_id') String get riderId;@JsonKey(name: 'driver_id') String? get driverId; String get status;@JsonKey(name: 'pickup_lat') double get originLat;@JsonKey(name: 'pickup_lng') double get originLng;@JsonKey(name: 'dest_lat') double get destLat;@JsonKey(name: 'dest_lng') double get destLng; double? get fare; String? get geohash;@JsonKey(name: 'created_at') DateTime? get createdAt;
/// Create a copy of TripModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TripModelCopyWith<TripModel> get copyWith => _$TripModelCopyWithImpl<TripModel>(this as TripModel, _$identity);

  /// Serializes this TripModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TripModel&&(identical(other.id, id) || other.id == id)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.status, status) || other.status == status)&&(identical(other.originLat, originLat) || other.originLat == originLat)&&(identical(other.originLng, originLng) || other.originLng == originLng)&&(identical(other.destLat, destLat) || other.destLat == destLat)&&(identical(other.destLng, destLng) || other.destLng == destLng)&&(identical(other.fare, fare) || other.fare == fare)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,riderId,driverId,status,originLat,originLng,destLat,destLng,fare,geohash,createdAt);

@override
String toString() {
  return 'TripModel(id: $id, riderId: $riderId, driverId: $driverId, status: $status, originLat: $originLat, originLng: $originLng, destLat: $destLat, destLng: $destLng, fare: $fare, geohash: $geohash, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TripModelCopyWith<$Res>  {
  factory $TripModelCopyWith(TripModel value, $Res Function(TripModel) _then) = _$TripModelCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'rider_id') String riderId,@JsonKey(name: 'driver_id') String? driverId, String status,@JsonKey(name: 'pickup_lat') double originLat,@JsonKey(name: 'pickup_lng') double originLng,@JsonKey(name: 'dest_lat') double destLat,@JsonKey(name: 'dest_lng') double destLng, double? fare, String? geohash,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class _$TripModelCopyWithImpl<$Res>
    implements $TripModelCopyWith<$Res> {
  _$TripModelCopyWithImpl(this._self, this._then);

  final TripModel _self;
  final $Res Function(TripModel) _then;

/// Create a copy of TripModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? riderId = null,Object? driverId = freezed,Object? status = null,Object? originLat = null,Object? originLng = null,Object? destLat = null,Object? destLng = null,Object? fare = freezed,Object? geohash = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,originLat: null == originLat ? _self.originLat : originLat // ignore: cast_nullable_to_non_nullable
as double,originLng: null == originLng ? _self.originLng : originLng // ignore: cast_nullable_to_non_nullable
as double,destLat: null == destLat ? _self.destLat : destLat // ignore: cast_nullable_to_non_nullable
as double,destLng: null == destLng ? _self.destLng : destLng // ignore: cast_nullable_to_non_nullable
as double,fare: freezed == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as double?,geohash: freezed == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [TripModel].
extension TripModelPatterns on TripModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TripModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TripModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TripModel value)  $default,){
final _that = this;
switch (_that) {
case _TripModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TripModel value)?  $default,){
final _that = this;
switch (_that) {
case _TripModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'rider_id')  String riderId, @JsonKey(name: 'driver_id')  String? driverId,  String status, @JsonKey(name: 'pickup_lat')  double originLat, @JsonKey(name: 'pickup_lng')  double originLng, @JsonKey(name: 'dest_lat')  double destLat, @JsonKey(name: 'dest_lng')  double destLng,  double? fare,  String? geohash, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TripModel() when $default != null:
return $default(_that.id,_that.riderId,_that.driverId,_that.status,_that.originLat,_that.originLng,_that.destLat,_that.destLng,_that.fare,_that.geohash,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'rider_id')  String riderId, @JsonKey(name: 'driver_id')  String? driverId,  String status, @JsonKey(name: 'pickup_lat')  double originLat, @JsonKey(name: 'pickup_lng')  double originLng, @JsonKey(name: 'dest_lat')  double destLat, @JsonKey(name: 'dest_lng')  double destLng,  double? fare,  String? geohash, @JsonKey(name: 'created_at')  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _TripModel():
return $default(_that.id,_that.riderId,_that.driverId,_that.status,_that.originLat,_that.originLng,_that.destLat,_that.destLng,_that.fare,_that.geohash,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'rider_id')  String riderId, @JsonKey(name: 'driver_id')  String? driverId,  String status, @JsonKey(name: 'pickup_lat')  double originLat, @JsonKey(name: 'pickup_lng')  double originLng, @JsonKey(name: 'dest_lat')  double destLat, @JsonKey(name: 'dest_lng')  double destLng,  double? fare,  String? geohash, @JsonKey(name: 'created_at')  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _TripModel() when $default != null:
return $default(_that.id,_that.riderId,_that.driverId,_that.status,_that.originLat,_that.originLng,_that.destLat,_that.destLng,_that.fare,_that.geohash,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TripModel extends TripModel {
  const _TripModel({required this.id, @JsonKey(name: 'rider_id') required this.riderId, @JsonKey(name: 'driver_id') this.driverId, required this.status, @JsonKey(name: 'pickup_lat') required this.originLat, @JsonKey(name: 'pickup_lng') required this.originLng, @JsonKey(name: 'dest_lat') required this.destLat, @JsonKey(name: 'dest_lng') required this.destLng, this.fare, this.geohash, @JsonKey(name: 'created_at') this.createdAt}): super._();
  factory _TripModel.fromJson(Map<String, dynamic> json) => _$TripModelFromJson(json);

@override final  String id;
@override@JsonKey(name: 'rider_id') final  String riderId;
@override@JsonKey(name: 'driver_id') final  String? driverId;
@override final  String status;
@override@JsonKey(name: 'pickup_lat') final  double originLat;
@override@JsonKey(name: 'pickup_lng') final  double originLng;
@override@JsonKey(name: 'dest_lat') final  double destLat;
@override@JsonKey(name: 'dest_lng') final  double destLng;
@override final  double? fare;
@override final  String? geohash;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;

/// Create a copy of TripModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TripModelCopyWith<_TripModel> get copyWith => __$TripModelCopyWithImpl<_TripModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TripModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TripModel&&(identical(other.id, id) || other.id == id)&&(identical(other.riderId, riderId) || other.riderId == riderId)&&(identical(other.driverId, driverId) || other.driverId == driverId)&&(identical(other.status, status) || other.status == status)&&(identical(other.originLat, originLat) || other.originLat == originLat)&&(identical(other.originLng, originLng) || other.originLng == originLng)&&(identical(other.destLat, destLat) || other.destLat == destLat)&&(identical(other.destLng, destLng) || other.destLng == destLng)&&(identical(other.fare, fare) || other.fare == fare)&&(identical(other.geohash, geohash) || other.geohash == geohash)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,riderId,driverId,status,originLat,originLng,destLat,destLng,fare,geohash,createdAt);

@override
String toString() {
  return 'TripModel(id: $id, riderId: $riderId, driverId: $driverId, status: $status, originLat: $originLat, originLng: $originLng, destLat: $destLat, destLng: $destLng, fare: $fare, geohash: $geohash, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TripModelCopyWith<$Res> implements $TripModelCopyWith<$Res> {
  factory _$TripModelCopyWith(_TripModel value, $Res Function(_TripModel) _then) = __$TripModelCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'rider_id') String riderId,@JsonKey(name: 'driver_id') String? driverId, String status,@JsonKey(name: 'pickup_lat') double originLat,@JsonKey(name: 'pickup_lng') double originLng,@JsonKey(name: 'dest_lat') double destLat,@JsonKey(name: 'dest_lng') double destLng, double? fare, String? geohash,@JsonKey(name: 'created_at') DateTime? createdAt
});




}
/// @nodoc
class __$TripModelCopyWithImpl<$Res>
    implements _$TripModelCopyWith<$Res> {
  __$TripModelCopyWithImpl(this._self, this._then);

  final _TripModel _self;
  final $Res Function(_TripModel) _then;

/// Create a copy of TripModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? riderId = null,Object? driverId = freezed,Object? status = null,Object? originLat = null,Object? originLng = null,Object? destLat = null,Object? destLng = null,Object? fare = freezed,Object? geohash = freezed,Object? createdAt = freezed,}) {
  return _then(_TripModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,riderId: null == riderId ? _self.riderId : riderId // ignore: cast_nullable_to_non_nullable
as String,driverId: freezed == driverId ? _self.driverId : driverId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,originLat: null == originLat ? _self.originLat : originLat // ignore: cast_nullable_to_non_nullable
as double,originLng: null == originLng ? _self.originLng : originLng // ignore: cast_nullable_to_non_nullable
as double,destLat: null == destLat ? _self.destLat : destLat // ignore: cast_nullable_to_non_nullable
as double,destLng: null == destLng ? _self.destLng : destLng // ignore: cast_nullable_to_non_nullable
as double,fare: freezed == fare ? _self.fare : fare // ignore: cast_nullable_to_non_nullable
as double?,geohash: freezed == geohash ? _self.geohash : geohash // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

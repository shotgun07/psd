// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverModel {

 String get id; String get userId; bool get isOnline; double? get currentLat; double? get currentLng; double get rating; String? get vehicleType; String? get vehiclePlate; String? get vehicleDetails; String get verificationStatus;
/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverModelCopyWith<DriverModel> get copyWith => _$DriverModelCopyWithImpl<DriverModel>(this as DriverModel, _$identity);

  /// Serializes this DriverModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.currentLat, currentLat) || other.currentLat == currentLat)&&(identical(other.currentLng, currentLng) || other.currentLng == currentLng)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehiclePlate, vehiclePlate) || other.vehiclePlate == vehiclePlate)&&(identical(other.vehicleDetails, vehicleDetails) || other.vehicleDetails == vehicleDetails)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,isOnline,currentLat,currentLng,rating,vehicleType,vehiclePlate,vehicleDetails,verificationStatus);

@override
String toString() {
  return 'DriverModel(id: $id, userId: $userId, isOnline: $isOnline, currentLat: $currentLat, currentLng: $currentLng, rating: $rating, vehicleType: $vehicleType, vehiclePlate: $vehiclePlate, vehicleDetails: $vehicleDetails, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class $DriverModelCopyWith<$Res>  {
  factory $DriverModelCopyWith(DriverModel value, $Res Function(DriverModel) _then) = _$DriverModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, bool isOnline, double? currentLat, double? currentLng, double rating, String? vehicleType, String? vehiclePlate, String? vehicleDetails, String verificationStatus
});




}
/// @nodoc
class _$DriverModelCopyWithImpl<$Res>
    implements $DriverModelCopyWith<$Res> {
  _$DriverModelCopyWithImpl(this._self, this._then);

  final DriverModel _self;
  final $Res Function(DriverModel) _then;

/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? isOnline = null,Object? currentLat = freezed,Object? currentLng = freezed,Object? rating = null,Object? vehicleType = freezed,Object? vehiclePlate = freezed,Object? vehicleDetails = freezed,Object? verificationStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,currentLat: freezed == currentLat ? _self.currentLat : currentLat // ignore: cast_nullable_to_non_nullable
as double?,currentLng: freezed == currentLng ? _self.currentLng : currentLng // ignore: cast_nullable_to_non_nullable
as double?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehiclePlate: freezed == vehiclePlate ? _self.vehiclePlate : vehiclePlate // ignore: cast_nullable_to_non_nullable
as String?,vehicleDetails: freezed == vehicleDetails ? _self.vehicleDetails : vehicleDetails // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverModel].
extension DriverModelPatterns on DriverModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverModel value)  $default,){
final _that = this;
switch (_that) {
case _DriverModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverModel value)?  $default,){
final _that = this;
switch (_that) {
case _DriverModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  bool isOnline,  double? currentLat,  double? currentLng,  double rating,  String? vehicleType,  String? vehiclePlate,  String? vehicleDetails,  String verificationStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverModel() when $default != null:
return $default(_that.id,_that.userId,_that.isOnline,_that.currentLat,_that.currentLng,_that.rating,_that.vehicleType,_that.vehiclePlate,_that.vehicleDetails,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  bool isOnline,  double? currentLat,  double? currentLng,  double rating,  String? vehicleType,  String? vehiclePlate,  String? vehicleDetails,  String verificationStatus)  $default,) {final _that = this;
switch (_that) {
case _DriverModel():
return $default(_that.id,_that.userId,_that.isOnline,_that.currentLat,_that.currentLng,_that.rating,_that.vehicleType,_that.vehiclePlate,_that.vehicleDetails,_that.verificationStatus);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  bool isOnline,  double? currentLat,  double? currentLng,  double rating,  String? vehicleType,  String? vehiclePlate,  String? vehicleDetails,  String verificationStatus)?  $default,) {final _that = this;
switch (_that) {
case _DriverModel() when $default != null:
return $default(_that.id,_that.userId,_that.isOnline,_that.currentLat,_that.currentLng,_that.rating,_that.vehicleType,_that.vehiclePlate,_that.vehicleDetails,_that.verificationStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverModel extends DriverModel {
  const _DriverModel({required this.id, required this.userId, this.isOnline = false, this.currentLat, this.currentLng, this.rating = 5.0, this.vehicleType, this.vehiclePlate, this.vehicleDetails, this.verificationStatus = 'pending'}): super._();
  factory _DriverModel.fromJson(Map<String, dynamic> json) => _$DriverModelFromJson(json);

@override final  String id;
@override final  String userId;
@override@JsonKey() final  bool isOnline;
@override final  double? currentLat;
@override final  double? currentLng;
@override@JsonKey() final  double rating;
@override final  String? vehicleType;
@override final  String? vehiclePlate;
@override final  String? vehicleDetails;
@override@JsonKey() final  String verificationStatus;

/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverModelCopyWith<_DriverModel> get copyWith => __$DriverModelCopyWithImpl<_DriverModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.isOnline, isOnline) || other.isOnline == isOnline)&&(identical(other.currentLat, currentLat) || other.currentLat == currentLat)&&(identical(other.currentLng, currentLng) || other.currentLng == currentLng)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.vehicleType, vehicleType) || other.vehicleType == vehicleType)&&(identical(other.vehiclePlate, vehiclePlate) || other.vehiclePlate == vehiclePlate)&&(identical(other.vehicleDetails, vehicleDetails) || other.vehicleDetails == vehicleDetails)&&(identical(other.verificationStatus, verificationStatus) || other.verificationStatus == verificationStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,isOnline,currentLat,currentLng,rating,vehicleType,vehiclePlate,vehicleDetails,verificationStatus);

@override
String toString() {
  return 'DriverModel(id: $id, userId: $userId, isOnline: $isOnline, currentLat: $currentLat, currentLng: $currentLng, rating: $rating, vehicleType: $vehicleType, vehiclePlate: $vehiclePlate, vehicleDetails: $vehicleDetails, verificationStatus: $verificationStatus)';
}


}

/// @nodoc
abstract mixin class _$DriverModelCopyWith<$Res> implements $DriverModelCopyWith<$Res> {
  factory _$DriverModelCopyWith(_DriverModel value, $Res Function(_DriverModel) _then) = __$DriverModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, bool isOnline, double? currentLat, double? currentLng, double rating, String? vehicleType, String? vehiclePlate, String? vehicleDetails, String verificationStatus
});




}
/// @nodoc
class __$DriverModelCopyWithImpl<$Res>
    implements _$DriverModelCopyWith<$Res> {
  __$DriverModelCopyWithImpl(this._self, this._then);

  final _DriverModel _self;
  final $Res Function(_DriverModel) _then;

/// Create a copy of DriverModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? isOnline = null,Object? currentLat = freezed,Object? currentLng = freezed,Object? rating = null,Object? vehicleType = freezed,Object? vehiclePlate = freezed,Object? vehicleDetails = freezed,Object? verificationStatus = null,}) {
  return _then(_DriverModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,isOnline: null == isOnline ? _self.isOnline : isOnline // ignore: cast_nullable_to_non_nullable
as bool,currentLat: freezed == currentLat ? _self.currentLat : currentLat // ignore: cast_nullable_to_non_nullable
as double?,currentLng: freezed == currentLng ? _self.currentLng : currentLng // ignore: cast_nullable_to_non_nullable
as double?,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,vehicleType: freezed == vehicleType ? _self.vehicleType : vehicleType // ignore: cast_nullable_to_non_nullable
as String?,vehiclePlate: freezed == vehiclePlate ? _self.vehiclePlate : vehiclePlate // ignore: cast_nullable_to_non_nullable
as String?,vehicleDetails: freezed == vehicleDetails ? _self.vehicleDetails : vehicleDetails // ignore: cast_nullable_to_non_nullable
as String?,verificationStatus: null == verificationStatus ? _self.verificationStatus : verificationStatus // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

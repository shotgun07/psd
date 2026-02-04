// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  email: json['email'] as String?,
  walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0.0,
  role: json['role'] as String? ?? 'client',
  rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
  kycStatus: json['kyc_status'] as String? ?? 'pending',
  profileImageUrl: json['profile_image_url'] as String?,
);

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'email': instance.email,
      'wallet_balance': instance.walletBalance,
      'role': instance.role,
      'rating': instance.rating,
      'kyc_status': instance.kycStatus,
      'profile_image_url': instance.profileImageUrl,
    };

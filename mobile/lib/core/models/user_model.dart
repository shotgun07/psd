import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String name,
    required String phone,
    String? email,
    @JsonKey(name: 'wallet_balance') @Default(0.0) double walletBalance,
    @Default('client') String role,
    @Default(5.0) double rating,
    @JsonKey(name: 'kyc_status') @Default('pending') String kycStatus,
    @JsonKey(name: 'profile_image_url') String? profileImageUrl,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

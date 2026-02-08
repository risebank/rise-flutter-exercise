// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'who_am_i_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhoAmIModel _$WhoAmIModelFromJson(Map<String, dynamic> json) => WhoAmIModel(
  user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
  permissions: (json['permissions'] as List<dynamic>)
      .map((e) => PermissionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WhoAmIModelToJson(WhoAmIModel instance) =>
    <String, dynamic>{
      'user': instance.user,
      'permissions': instance.permissions,
    };

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'name': instance.name,
};

PermissionModel _$PermissionModelFromJson(Map<String, dynamic> json) =>
    PermissionModel(
      companyId: json['company_id'] as String,
      companyName: json['company_name'] as String?,
      role: json['role'] as String?,
    );

Map<String, dynamic> _$PermissionModelToJson(PermissionModel instance) =>
    <String, dynamic>{
      'company_id': instance.companyId,
      'company_name': instance.companyName,
      'role': instance.role,
    };

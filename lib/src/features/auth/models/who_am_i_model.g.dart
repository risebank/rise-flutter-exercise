// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'who_am_i_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhoAmIModel _$WhoAmIModelFromJson(Map<String, dynamic> json) => WhoAmIModel(
  id: json['id'] as String,
  email: json['email'] as String,
  name: json['name'] as String?,
  companyId: json['companyId'] as String?,
);

Map<String, dynamic> _$WhoAmIModelToJson(WhoAmIModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'companyId': instance.companyId,
    };

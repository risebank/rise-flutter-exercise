import 'package:json_annotation/json_annotation.dart';

part 'who_am_i_model.g.dart';

@JsonSerializable()
class WhoAmIModel {
  final UserModel user;
  final List<PermissionModel> permissions;

  const WhoAmIModel({required this.user, required this.permissions});

  factory WhoAmIModel.fromJson(Map<String, dynamic> json) =>
      _$WhoAmIModelFromJson(json);

  Map<String, dynamic> toJson() => _$WhoAmIModelToJson(this);

  /// Get the first company ID from permissions (for exercise simplicity)
  String? get companyId {
    if (permissions.isNotEmpty) {
      return permissions.first.companyId;
    }
    return null;
  }
}

@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String? name;

  const UserModel({required this.id, required this.email, this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class PermissionModel {
  @JsonKey(name: 'company_id')
  final String companyId;
  @JsonKey(name: 'company_name')
  final String? companyName;
  final String? role;

  const PermissionModel({required this.companyId, this.companyName, this.role});

  factory PermissionModel.fromJson(Map<String, dynamic> json) =>
      _$PermissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$PermissionModelToJson(this);
}

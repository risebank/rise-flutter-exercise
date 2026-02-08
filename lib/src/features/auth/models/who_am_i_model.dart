import 'package:json_annotation/json_annotation.dart';

part 'who_am_i_model.g.dart';

@JsonSerializable()
class WhoAmIModel {
  final String id;
  final String email;
  final String? name;
  final String? companyId;

  const WhoAmIModel({
    required this.id,
    required this.email,
    this.name,
    this.companyId,
  });

  factory WhoAmIModel.fromJson(Map<String, dynamic> json) =>
      _$WhoAmIModelFromJson(json);

  Map<String, dynamic> toJson() => _$WhoAmIModelToJson(this);
}

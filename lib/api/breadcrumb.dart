import 'package:json_annotation/json_annotation.dart';

part 'breadcrumb.g.dart';

@JsonSerializable()
class Breadcrumb {
  final String id;
  final String name;
  final String parentId;

  Breadcrumb({
    required this.id,
    required this.name,
    required this.parentId,
  });

  factory Breadcrumb.fromJson(Map<String, dynamic> json) => _$BreadcrumbFromJson(json);
  Map<String, dynamic> toJson() => _$BreadcrumbToJson(this);
}

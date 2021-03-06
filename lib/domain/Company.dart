import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'Address.dart';

part 'Company.g.dart';

@JsonSerializable(explicitToJson: true)
class Company extends Equatable {
  final String name;
  final String taxIdentification;
  final Address address;

  Company({this.name, this.taxIdentification, this.address});

  @override
  List<Object> get props => [name, taxIdentification, address];

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyToJson(this);

  @override
  String toString() => jsonEncode(this.toJson());
}

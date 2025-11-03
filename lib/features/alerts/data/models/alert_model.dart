import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../domain/enums/alert_risk.dart';
import '../../domain/enums/alert_type.dart';

part 'alert_model.g.dart';

@JsonSerializable()
class AlertModel extends Equatable {
  final String? uid;
  final String titulo;
  final String descricao;
  final AlertType tipo;
  final AlertRisk risco;
  final DateTime data;
  final double latitude;
  final double longitude;

  const AlertModel({
    this.uid,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.risco,
    required this.data,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
    uid,
    titulo,
    descricao,
    titulo,
    risco,
    data,
    latitude,
    longitude,
  ];

  AlertModel fromJson(Map<String, dynamic> json) => _$AlertModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlertModelToJson(this);
}

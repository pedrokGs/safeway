import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';

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
  final String userId;

  const AlertModel({
    this.uid,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.risco,
    required this.data,
    required this.latitude,
    required this.longitude,
    required this.userId
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
    userId,
  ];

  AlertModel copyWith({
    String? uid,
    String? titulo,
    String? descricao,
    AlertType? tipo,
    AlertRisk? risco,
    DateTime? data,
    double? latitude,
    double? longitude,
    String? userId
  }) {
    return AlertModel(
        uid: uid ?? this.uid ?? '',
        titulo: titulo ?? this.titulo,
        descricao: descricao ?? this.descricao,
        tipo: tipo ?? this.tipo,
        risco: risco ?? this.risco,
        data: data ?? this.data,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        userId: userId ?? this.userId
    );
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) => _$AlertModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlertModelToJson(this);

  AlertEntity toEntity() => AlertEntity(uid: uid ?? '', titulo: titulo, descricao: descricao, tipo: tipo, risco: risco, data: data, latitude: latitude, longitude: longitude, userId: userId);
}

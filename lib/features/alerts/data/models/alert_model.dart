import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/enums/alert_risk.dart';
import '../../domain/enums/alert_type.dart';

part 'alert_model.g.dart';

class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) {
      return json.toDate();
    } else if (json is String) {
      return DateTime.parse(json);
    } else {
      throw ArgumentError('Tipo inválido para conversão de data: $json');
    }
  }

  @override
  Object toJson(DateTime date) => date.toIso8601String();
}

@JsonSerializable()
class AlertModel extends Equatable {
  final String uid;
  final String titulo;
  final String descricao;
  final AlertType tipo;
  final AlertRisk risco;

  @TimestampConverter()
  final DateTime data;
  final double latitude;
  final double longitude;
  final String userId;

  const AlertModel({
    required this.uid,
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
        uid: uid ?? this.uid,
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

  factory AlertModel.fromEntity(AlertEntity entity) => AlertModel(uid: entity.uid, titulo: entity.titulo, descricao: entity.descricao, tipo: entity.tipo, risco: entity.risco, data: entity.data, latitude: entity.latitude, longitude: entity.longitude, userId: entity.userId);
}

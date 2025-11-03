import 'package:equatable/equatable.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/domain/enums/alert_type.dart';

class AlertEntity extends Equatable {
  final String uid;
  final String titulo;
  final String descricao;
  final AlertType tipo;
  final AlertRisk risco;
  final DateTime data;
  final double latitude;
  final double longitude;
  final String userId;

  const AlertEntity({
    required this.uid,
    required this.titulo,
    required this.descricao,
    required this.tipo,
    required this.risco,
    required this.data,
    required this.latitude,
    required this.longitude,
    required this.userId,
  });

  AlertEntity copyWith({
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
    return AlertEntity(
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

  @override
  List<Object?> get props => [
    uid,
    titulo,
    descricao,
    tipo,
    risco,
    data,
    latitude,
    longitude,
    userId
  ];
}

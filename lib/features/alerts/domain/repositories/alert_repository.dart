import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';

import '../enums/alert_risk.dart';
import '../enums/alert_type.dart';

abstract interface class AlertRepository{
  // Retorna todos os alertas em uma lista, ou [] caso não tenha nenhum, com outros metodos para filtragem
  Future<List<AlertEntity>> getAllAlerts();
  Future<List<AlertEntity>> getAlertsByType(AlertType type);
  Future<List<AlertEntity>> getAlertsByRisk(AlertRisk risk);

  Future<void> deleteAlertById(String id);

  // Atualiza um AlertEntity, usa o copyWith da classe para atualizar
  Future<AlertEntity> updateAlert(AlertEntity alertEntity);

  Future<AlertEntity> createAlert(AlertEntity alertEntity);

  // Observa os alertas em tempo real
  Stream<List<AlertEntity>> watchAllAlerts();
}
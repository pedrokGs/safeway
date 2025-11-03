import 'package:safeway/features/alerts/data/models/alert_model.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/domain/enums/alert_type.dart';

abstract interface class AlertRemoteDataSource {
  Future<List<AlertModel>> getAllAlerts();
  Future<List<AlertModel>> getAlertsByType(AlertType type);
  Future<List<AlertModel>> getAlertsByRisk(AlertRisk risk);

  Future<void> deleteAlertById(String id);

  Future<AlertModel> updateAlert(AlertModel model);

  Future<AlertModel> createAlert(AlertModel model);

  Stream<List<AlertModel>> watchAllAlerts();
}

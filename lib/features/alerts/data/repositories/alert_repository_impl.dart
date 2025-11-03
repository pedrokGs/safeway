import 'package:safeway/features/alerts/data/datasources/alert_remote_datasource.dart';
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/domain/enums/alert_type.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class AlertRepositoryImpl implements AlertRepository{
  final AlertRemoteDataSource datasource;

  const AlertRepositoryImpl({required this.datasource});

  @override
  Future<AlertEntity> createAlert(AlertEntity alertEntity) {
    // TODO: implement createAlert
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAlertById(String id) {
    // TODO: implement deleteAlertById
    throw UnimplementedError();
  }

  @override
  Future<List<AlertEntity>> getAlertsByRisk(AlertRisk risk) {
    // TODO: implement getAlertsByRisk
    throw UnimplementedError();
  }

  @override
  Future<List<AlertEntity>> getAlertsByType(AlertType type) {
    // TODO: implement getAlertsByType
    throw UnimplementedError();
  }

  @override
  Future<List<AlertEntity>> getAllAlerts() {
    // TODO: implement getAllAlerts
    throw UnimplementedError();
  }

  @override
  Future<AlertEntity> updateAlert(AlertEntity alertEntity) {
    // TODO: implement updateAlert
    throw UnimplementedError();
  }

  @override
  Stream<List<AlertEntity>> watchAllAlerts() {
    // TODO: implement watchAllAlerts
    throw UnimplementedError();
  }

}
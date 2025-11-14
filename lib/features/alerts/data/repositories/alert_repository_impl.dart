import 'dart:developer';

import 'package:safeway/common/exceptions/invalid_argument_exception.dart';
import 'package:safeway/features/alerts/data/datasources/alert_remote_datasource.dart';
import 'package:safeway/features/alerts/data/models/alert_model.dart';
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/domain/enums/alert_type.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class AlertRepositoryImpl implements AlertRepository {
  final AlertRemoteDataSource datasource;

  const AlertRepositoryImpl({required this.datasource});

  @override
  Future<AlertEntity> createAlert(AlertEntity alertEntity) async {
    final model = await datasource.createAlert(
      AlertModel.fromEntity(alertEntity)
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteAlertById(String id) async {
    await datasource.deleteAlertById(id);
  }

  @override
  Future<List<AlertEntity>> getAlertsByRisk(AlertRisk risk) async {
    final result = await datasource.getAlertsByRisk(risk);
    return result.whereType<AlertModel>().map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<AlertEntity>> getAlertsByType(AlertType type) async {
    final result = await datasource.getAlertsByType(type);
    return result.whereType<AlertModel>().map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<AlertEntity>> getAllAlerts() async {
    final result = await datasource.getAllAlerts();
    return result.whereType<AlertModel>().map((e) => e.toEntity()).toList();
  }

  @override
  Future<AlertEntity> updateAlert(AlertEntity alertEntity) async {
    final result = await datasource.updateAlert(
        AlertModel.fromEntity(alertEntity)
    );
    return result.toEntity();
  }

  @override
  Stream<List<AlertEntity>> watchAllAlerts() {
    return datasource
        .watchAllAlerts()
        .map((list) => list.map((e) => e.toEntity()).toList())
        .handleError((e) {
          log("Alert repository: updateAlert");
          throw InvalidArgumentException();
        });
  }
}

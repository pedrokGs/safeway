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

  // TODO: Validação de erro melhor

  @override
  Future<AlertEntity> createAlert(AlertEntity alertEntity) async {
    try {
      final model = await datasource.createAlert(
        AlertModel(
          titulo: alertEntity.titulo,
          descricao: alertEntity.descricao,
          tipo: alertEntity.tipo,
          risco: alertEntity.risco,
          data: alertEntity.data,
          latitude: alertEntity.latitude,
          longitude: alertEntity.longitude,
          userId: alertEntity.userId
        ),
      );
      return model.toEntity();
    } catch (e) {
      log("Alert Repository: createAlert");
      throw InvalidArgumentException();
    }
  }

  @override
  Future<void> deleteAlertById(String id) async {
    try {
      await datasource.deleteAlertById(id);
    } catch (e) {
      log("Alert Repository: deleteAlertById");
      throw InvalidArgumentException();
    }
  }

  @override
  Future<List<AlertEntity?>> getAlertsByRisk(AlertRisk risk) async {
    try {
      final result = await datasource.getAlertsByRisk(risk);
      return result.whereType<AlertModel>().map((e) => e.toEntity()).toList();
    } catch (e) {
      log("Alert Repository: getAlertsByRisk");
      throw InvalidArgumentException();
    }
  }

  @override
  Future<List<AlertEntity?>> getAlertsByType(AlertType type) async {
    try {
      final result = await datasource.getAlertsByType(type);
      return result.whereType<AlertModel>().map((e) => e.toEntity()).toList();
    } catch (e) {
      log("Alert repository: getAlertsByType");
      throw InvalidArgumentException();
    }
  }

  @override
  Future<List<AlertEntity?>> getAllAlerts() async {
    try {
      final result = await datasource.getAllAlerts();
      return result.whereType<AlertModel>().map((e) => e.toEntity()).toList();
    } catch (e) {
      log("Alert repository: getAlertsByType");
      throw InvalidArgumentException();
    }
  }

  @override
  Future<AlertEntity> updateAlert(AlertEntity alertEntity) async {
    try {
      final result = await datasource.updateAlert(
        AlertModel(
          titulo: alertEntity.titulo,
          descricao: alertEntity.descricao,
          tipo: alertEntity.tipo,
          risco: alertEntity.risco,
          data: alertEntity.data,
          latitude: alertEntity.latitude,
          longitude: alertEntity.longitude,
          userId: alertEntity.userId
        ),
      );
      return result.toEntity();
    } catch (e) {
      log("Alert repository: updateAlert");
      throw InvalidArgumentException();
    }
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

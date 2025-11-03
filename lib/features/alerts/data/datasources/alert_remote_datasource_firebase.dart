import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safeway/features/alerts/data/datasources/alert_remote_datasource.dart';
import 'package:safeway/features/alerts/data/models/alert_model.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/domain/enums/alert_type.dart';
import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

class AlertRemoteDataSourceFirebase implements AlertRemoteDataSource {
  final FirebaseFirestore firestore;
  final AuthRepository authRepository;

  const AlertRemoteDataSourceFirebase({required this.firestore, required this.authRepository});

  @override
  Future<AlertModel> createAlert(AlertModel model) {
    // TODO: implement createAlert
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAlertById(String id) {
    // TODO: implement deleteAlertById
    throw UnimplementedError();
  }

  @override
  Future<List<AlertModel>> getAlertsByRisk(AlertRisk risk) {
    // TODO: implement getAlertsByRisk
    throw UnimplementedError();
  }

  @override
  Future<List<AlertModel>> getAlertsByType(AlertType type) {
    // TODO: implement getAlertsByType
    throw UnimplementedError();
  }

  @override
  Future<List<AlertModel>> getAllAlerts() {
    // TODO: implement getAllAlerts
    throw UnimplementedError();
  }

  @override
  Future<AlertModel> updateAlert(AlertModel model) {
    // TODO: implement updateAlert
    throw UnimplementedError();
  }

  @override
  Stream<List<AlertModel>> watchAllAlerts() {
    // TODO: implement watchAllAlerts
    throw UnimplementedError();
  }

}
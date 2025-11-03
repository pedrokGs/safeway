import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safeway/common/exceptions/data_source_exception.dart';
import 'package:safeway/common/exceptions/invalid_argument_exception.dart';
import 'package:safeway/common/exceptions/permission_denied_exception.dart';
import 'package:safeway/common/exceptions/unauthorized_exception.dart';
import 'package:safeway/common/exceptions/unknown_data_source_exception.dart';
import 'package:safeway/features/alerts/data/datasources/alert_remote_datasource.dart';
import 'package:safeway/features/alerts/data/models/alert_model.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/domain/enums/alert_type.dart';
import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

class AlertRemoteDataSourceFirebase implements AlertRemoteDataSource {
  final FirebaseFirestore firestore;
  final AuthRepository authRepository;

  // TODO: Melhorar todas os tratamentos de erros

  const AlertRemoteDataSourceFirebase({required this.firestore, required this.authRepository});

  @override
  Future<AlertModel> createAlert(AlertModel model) async {
    try{
      final modelWithUserId = model.copyWith(userId: authRepository.currentUser!.id);

      final docRef = await firestore.collection('alerts').add(modelWithUserId.toJson());
      return modelWithUserId.copyWith(uid: docRef.id);
    } on FirebaseException catch(e){
      switch (e.code){
        case 'invalid-argument':
          throw InvalidArgumentException();
        case 'permission-denied':
          throw PermissionDeniedException();
        case 'unauthenticated':
          throw UnauthenticatedException();
      }
      throw DataSourceException('Erro desconhecido: ${e.code}');
    } catch(e){
      throw UnknownDataSourceException();
    }
  }

  @override
  Future<void> deleteAlertById(String id)  async{
    try{
      await firestore.collection('alerts').doc(id).delete();
    } on FirebaseException catch(e){
      switch (e.code){
        case 'invalid-argument':
          throw InvalidArgumentException();
        case 'permission-denied':
          throw PermissionDeniedException();
        case 'unauthenticated':
          throw UnauthenticatedException();
      }
      throw DataSourceException('Erro desconhecido: ${e.code}');
    } catch(e){
      throw UnknownDataSourceException();
    }
  }

  @override
  Future<List<AlertModel?>> getAlertsByRisk(AlertRisk risk) async {
    try{
      final snapshot = await firestore.collection('alerts').where("risk", isEqualTo: risk).get();

      final alertModelsList = snapshot.docs.map((e) {
        return AlertModel.fromJson(e.data());
      },).toList();

      return alertModelsList;
    }on FirebaseException catch(e){
      switch (e.code){
        case 'invalid-argument':
          throw InvalidArgumentException();
        case 'permission-denied':
          throw PermissionDeniedException();
        case 'unauthenticated':
          throw UnauthenticatedException();
      }
      throw DataSourceException('Erro desconhecido: ${e.code}');
    } catch(e){
      throw UnknownDataSourceException();
    }
  }

  @override
  Future<List<AlertModel?>> getAlertsByType(AlertType type) {
    // TODO: implement getAlertsByType
    throw UnimplementedError();
  }

  @override
  Future<List<AlertModel?>> getAllAlerts() {
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
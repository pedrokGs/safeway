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
import 'package:safeway/features/alerts/domain/exceptions/alert_not_found_exception.dart';
import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

class AlertRemoteDataSourceFirebase implements AlertRemoteDataSource {
  final FirebaseFirestore firestore;
  final AuthRepository authRepository;

  const AlertRemoteDataSourceFirebase({
    required this.firestore,
    required this.authRepository,
  });

  Never _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'invalid-argument':
        throw InvalidArgumentException();
      case 'permission-denied':
        throw PermissionDeniedException();
      case 'unauthenticated':
        throw UnauthenticatedException();
      case 'not-found':
        throw AlertNotFoundException();
      default:
        throw DataSourceException('Erro desconhecido: ${e.code}');
    }
  }

  @override
  Future<AlertModel> createAlert(AlertModel model) async {
    try {
      final user = authRepository.currentUser;
      if (user == null) throw UnauthenticatedException();

      final modelWithUserId = model.copyWith(userId: user.id);
      final docRef = await firestore.collection('alerts').add(modelWithUserId.toJson());
      return modelWithUserId.copyWith(uid: docRef.id);
    } on FirebaseException catch (e) {
      _handleFirebaseException(e);
    } on UnauthenticatedException catch (_) {
      rethrow;
    } catch(e){
      throw UnknownDataSourceException(error: 'Erro desconhecido: $e');
    }
  }

  @override
  Future<void> deleteAlertById(String id) async {
    try {
      await firestore.collection('alerts').doc(id).delete();
    } on FirebaseException catch (e) {
      _handleFirebaseException(e);
    } catch (_) {
      throw UnknownDataSourceException();
    }
  }

  @override
  Future<List<AlertModel>> getAllAlerts() async {
    try {
      final snapshot = await firestore
          .collection('alerts')
          .orderBy('data', descending: true)
          .get();

      final alertModelsList = snapshot.docs.map((e) {
        final data = e.data();
        return AlertModel.fromJson({
          ...data,
          'uid': e.id,
        });
      }).toList();

      return alertModelsList;
    } on FirebaseException catch (e) {
      _handleFirebaseException(e);
    } catch (e) {
      throw UnknownDataSourceException(error: e.toString());
    }
  }


  @override
  Future<List<AlertModel>> getAlertsByType(AlertType type) async {
    try {
      final snapshot = await firestore
          .collection('alerts')
          .where('tipo', isEqualTo: type.name)
          .orderBy('data', descending: true)
          .get();

      final alertModelsList = snapshot.docs.map((e) {
        final data = e.data();
        return AlertModel.fromJson({
          ...data,
          'uid': e.id,
        });
      }).toList();

      return alertModelsList;
    } on FirebaseException catch (e) {
      _handleFirebaseException(e);
    } catch (e) {
      throw UnknownDataSourceException(error: e.toString());
    }
  }


  @override
  Future<List<AlertModel>> getAlertsByRisk(AlertRisk risk) async {
    try {
      final snapshot = await firestore
          .collection('alerts')
          .where('risco', isEqualTo: risk.name)
          .orderBy('data', descending: true)
          .get();

      final alertModelsList = snapshot.docs.map((e) {
        final data = e.data();
        return AlertModel.fromJson({
          ...data,
          'uid': e.id,
        });
      }).toList();

      return alertModelsList;
    } on FirebaseException catch (e) {
      _handleFirebaseException(e);
    } catch (e) {
      throw UnknownDataSourceException(error: e.toString());
    }
  }

  @override
  Future<AlertModel> updateAlert(AlertModel model) async {
    try {
      await firestore.collection('alerts').doc(model.uid).update(model.toJson());
      return model;
    } on FirebaseException catch (e) {
      _handleFirebaseException(e);
    } catch (_) {
      throw UnknownDataSourceException();
    }
  }

  @override
  Stream<List<AlertModel>> watchAllAlerts() async* {
    try {
      yield* firestore.collection('alerts').snapshots().map(
            (snapshot) => snapshot.docs
            .map((doc) => AlertModel.fromJson({...doc.data(), 'uid': doc.id}))
            .toList(),
      );
    } on FirebaseException catch (e) {
      _handleFirebaseException(e);
    } catch (_) {
      throw UnknownDataSourceException();
    }
  }


}

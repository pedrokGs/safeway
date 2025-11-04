import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/common/exceptions/data_source_exception.dart';
import 'package:safeway/common/exceptions/unauthorized_exception.dart';
import 'package:safeway/common/exceptions/unknown_data_source_exception.dart';
import 'package:safeway/core/di/alert_providers.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/alerts/data/models/alert_model.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/domain/enums/alert_type.dart';
import 'package:safeway/features/alerts/domain/exceptions/alert_not_found_exception.dart';
import 'package:safeway/features/auth/domain/entities/auth_user_entity.dart';
import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore firestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocRef;
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;

  setUp(() {
    firestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockAuthRepository = MockAuthRepository();

    container = ProviderContainer(
      overrides: [
        cloudFirestoreProvider.overrideWithValue(firestore),
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );

    addTearDown(container.dispose);
  });

  final AuthUserEntity tUser = AuthUserEntity(id: 'user123', email: 'test@gmail.com');

  final tAlerta = AlertModel(
      uid: '1',
      titulo: 'Alerta de Incêndio',
      descricao: 'Fogo detectado na área industrial',
      tipo: AlertType.incendio,
      risco: AlertRisk.alto,
      data: DateTime(2025, 11, 1, 14, 30),
      latitude: -23.5505,
      longitude: -46.6333,
      userId: '123'
  );

  final tAlerta2 = AlertModel(
      uid: '2',
      titulo: 'Alerta de Enchente',
      descricao: 'Risco de enchente no centro da cidade',
      tipo: AlertType.enchente,
      risco: AlertRisk.medio,
      data: DateTime(2025, 11, 1, 14, 30),
      latitude: -23.5505,
      longitude: -46.6333,
      userId: '123'
  );

  Map<String, dynamic> _mapFromAlert(AlertModel a) {
    return {
      'titulo': a.titulo,
      'descricao': a.descricao,
      'tipo': a.tipo.name,
      'risco': a.risco.name,
      'data': Timestamp.fromDate(a.data),
      'latitude': a.latitude,
      'longitude': a.longitude,
      'userId': a.userId,
    };
  }

  group('createAlert', () {
    test('deve criar um alerta e retornar o modelo com id e userId preenchidos', () async {
      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.add(any())).thenAnswer((_) async => mockDocRef);
      when(() => mockDocRef.id).thenReturn('alert123');
      when(() => mockAuthRepository.currentUser).thenReturn(tUser);

      final dataSource = container.read(alertRemoteDataSourceProvider);

      final result = await dataSource.createAlert(tAlerta);

      expect(result.uid, equals('alert123'));
      expect(result.userId, equals('user123'));

      verify(() => firestore.collection('alerts')).called(1);
      verify(() => mockCollection.add(any())).called(1);
      verify(() => mockAuthRepository.currentUser).called(1);
    });

    test('deve lançar UnknownDataSourceException quando o Firestore falhar', () async {
      when(() => firestore.collection('alerts')).thenThrow(Exception('Firestore error'));
      when(() => mockAuthRepository.currentUser).thenReturn(tUser);

      final dataSource = container.read(alertRemoteDataSourceProvider);
      await expectLater(dataSource.createAlert(tAlerta), throwsA(isA<UnknownDataSourceException>()));
    });

    test('deve lançar UnauthenticatedException se não houver usuário autenticado', () async {
      when(() => mockAuthRepository.currentUser).thenReturn(null);

      final dataSource = container.read(alertRemoteDataSourceProvider);

      await expectLater(dataSource.createAlert(tAlerta),
        throwsA(isA<UnauthenticatedException>()),
      );
      verifyNever(() => firestore.collection(any()));
    });
  });

  group('getAllAlerts', () {
    test('deve retornar lista de alertas ordenados por data desc', () async {
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDocSnap1 = MockQueryDocumentSnapshot();
      final mockDocSnap2 = MockQueryDocumentSnapshot();

      final map1 = _mapFromAlert(tAlerta);
      final map2 = _mapFromAlert(tAlerta2);

      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.orderBy('data', descending: true)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockDocSnap1, mockDocSnap2]);

      when(() => mockDocSnap1.data()).thenReturn(map1);
      when(() => mockDocSnap1.id).thenReturn(tAlerta.uid);
      when(() => mockDocSnap2.data()).thenReturn(map2);
      when(() => mockDocSnap2.id).thenReturn(tAlerta2.uid);

      final dataSource = container.read(alertRemoteDataSourceProvider);
      final result = await dataSource.getAllAlerts();

      expect(result, isA<List<AlertModel>>());
      expect(result.length, equals(2));
      expect(result[0]?.titulo, equals(tAlerta.titulo));
      expect(result[1]?.titulo, equals(tAlerta2.titulo));

      verify(() => firestore.collection('alerts')).called(1);
      verify(() => mockCollection.orderBy('data', descending: true)).called(1);
      verify(() => mockQuery.get()).called(1);
    });

    test('deve lançar UnknownDataSourceException quando ocorrer erro no Firestore', () async {
      when(() => firestore.collection('alerts')).thenThrow(Exception('Firestore failed'));
      final dataSource = container.read(alertRemoteDataSourceProvider);
      expect(() => dataSource.getAllAlerts(), throwsA(isA<UnknownDataSourceException>()));
    });

    test('deve retornar lista vazia quando snapshot não tiver documentos', () async {
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();

      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.orderBy('data', descending: true)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      final dataSource = container.read(alertRemoteDataSourceProvider);
      final result = await dataSource.getAllAlerts();

      expect(result, isEmpty);
    });
  });

  group('getAlertsByType', () {
    test('deve retornar apenas alertas do tipo solicitado', () async {
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDocSnap1 = MockQueryDocumentSnapshot();

      final map1 = _mapFromAlert(tAlerta);

      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.where('tipo', isEqualTo: tAlerta.tipo.name)).thenReturn(mockQuery);
      when(() => mockQuery.orderBy('data', descending: true)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockDocSnap1]);

      when(() => mockDocSnap1.data()).thenReturn(map1);
      when(() => mockDocSnap1.id).thenReturn(tAlerta.uid);

      final dataSource = container.read(alertRemoteDataSourceProvider);
      final result = await dataSource.getAlertsByType(tAlerta.tipo);

      expect(result, isA<List<AlertModel>>());
      expect(result.length, equals(1));
      expect(result[0]?.tipo, equals(tAlerta.tipo));

      verify(() => firestore.collection('alerts')).called(1);
      verify(() => mockCollection.where('tipo', isEqualTo: tAlerta.tipo.name)).called(1);
      verify(() => mockQuery.get()).called(1);
    });

    test('deve lançar UnknownDataSourceException quando o query falhar', () async {
      when(() => firestore.collection('alerts')).thenThrow(Exception('Query error'));
      final dataSource = container.read(alertRemoteDataSourceProvider);
      expect(() => dataSource.getAlertsByType(AlertType.incendio), throwsA(isA<UnknownDataSourceException>()));
    });

    test('deve retornar lista vazia quando não houver alertas do tipo solicitado', () async {
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();

      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.where('tipo', isEqualTo: AlertType.incendio.name)).thenReturn(mockQuery);
      when(() => mockQuery.orderBy('data', descending: true)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      final dataSource = container.read(alertRemoteDataSourceProvider);
      final result = await dataSource.getAlertsByType(AlertType.incendio);

      expect(result, isEmpty);
    });
  });

  group('getAlertsByRisk', () {
    test('deve retornar apenas alertas com o risco solicitado', () async {
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDocSnap1 = MockQueryDocumentSnapshot();

      final map1 = _mapFromAlert(tAlerta);

      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.where('risco', isEqualTo: tAlerta.risco.name)).thenReturn(mockQuery);
      when(() => mockQuery.orderBy('data', descending: true)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockDocSnap1]);

      when(() => mockDocSnap1.data()).thenReturn(map1);
      when(() => mockDocSnap1.id).thenReturn(tAlerta.uid);

      final dataSource = container.read(alertRemoteDataSourceProvider);
      final result = await dataSource.getAlertsByRisk(tAlerta.risco);

      expect(result, isA<List<AlertModel>>());
      expect(result.length, equals(1));
      expect(result[0]?.risco, equals(tAlerta.risco));

      verify(() => firestore.collection('alerts')).called(1);
      verify(() => mockCollection.where('risco', isEqualTo: tAlerta.risco.name)).called(1);
      verify(() => mockQuery.get()).called(1);
    });

    test('deve lançar UnknownDataSourceException quando o query falhar', () async {
      when(() => firestore.collection('alerts')).thenThrow(Exception('Firestore broke'));
      final dataSource = container.read(alertRemoteDataSourceProvider);
      expect(() => dataSource.getAlertsByRisk(AlertRisk.alto), throwsA(isA<UnknownDataSourceException>()));
    });

    test('deve retornar lista vazia quando não houver alertas com o risco solicitado', () async {
      final mockQuery = MockQuery();
      final mockQuerySnapshot = MockQuerySnapshot();

      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.where('risco', isEqualTo: AlertRisk.alto.name)).thenReturn(mockQuery);
      when(() => mockQuery.orderBy('data', descending: true)).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      final dataSource = container.read(alertRemoteDataSourceProvider);
      final result = await dataSource.getAlertsByRisk(AlertRisk.alto);

      expect(result, isEmpty);
    });
  });

  group('deleteAlertById', () {
    test('deve chamar delete no documento correspondente', () async {
      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.doc('some-id')).thenReturn(mockDocRef);
      when(() => mockDocRef.delete()).thenAnswer((_) async => Future.value());

      final dataSource = container.read(alertRemoteDataSourceProvider);
      await dataSource.deleteAlertById('some-id');

      verify(() => firestore.collection('alerts')).called(1);
      verify(() => mockCollection.doc('some-id')).called(1);
      verify(() => mockDocRef.delete()).called(1);
    });

    test('deve lançar UnknownDataSourceException se delete falhar', () async {
      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDocRef);
      when(() => mockDocRef.delete()).thenThrow(Exception('Falha ao deletar'));
      final dataSource = container.read(alertRemoteDataSourceProvider);
      expect(() => dataSource.deleteAlertById('some-id'), throwsA(isA<UnknownDataSourceException>()));
    });

    test('deve lançar AlertNotFoundException se documento não existir', () async {
      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.doc('inexistente')).thenReturn(mockDocRef);
      when(() => mockDocRef.delete()).thenThrow(FirebaseException(plugin: 'Firestore', code: 'not-found'));

      final dataSource = container.read(alertRemoteDataSourceProvider);
      expect(() => dataSource.deleteAlertById('inexistente'), throwsA(isA<AlertNotFoundException>()));
    });
  });

  group('updateAlert', () {
    test('deve atualizar o documento e retornar o modelo atualizado', () async {
      final updated = tAlerta.copyWith(titulo: 'Alerta de Incêndio - Atualizado');

      final updatedMap = _mapFromAlert(updated);

      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.doc(updated.uid)).thenReturn(mockDocRef);
      when(() => mockDocRef.update(any())).thenAnswer((_) async => Future.value());

      final mockDocSnapshot = MockDocumentSnapshot();
      when(() => mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.data()).thenReturn(updatedMap);
      when(() => mockDocSnapshot.id).thenReturn(updated.uid);

      final dataSource = container.read(alertRemoteDataSourceProvider);
      final result = await dataSource.updateAlert(updated);

      expect(result, isA<AlertModel>());
      expect(result.uid, equals(updated.uid));
      expect(result.titulo, equals('Alerta de Incêndio - Atualizado'));

      verify(() => firestore.collection('alerts')).called(1);
      verify(() => mockCollection.doc(updated.uid)).called(1);
      verify(() => mockDocRef.update(any())).called(1);
    });

    test('deve lançar UnknownDataSourceException se update falhar', () async {
      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.doc(any())).thenReturn(mockDocRef);
      when(() => mockDocRef.update(any())).thenThrow(Exception('update failed'));
      final dataSource = container.read(alertRemoteDataSourceProvider);
      expect(() => dataSource.updateAlert(tAlerta), throwsA(isA<UnknownDataSourceException>()));
    });

    test('deve lançar AlertNotFoundException se documento não for encontrado', () async {
      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.doc(tAlerta.uid)).thenThrow(FirebaseException(plugin: 'Firestore', code: 'not-found'));

      final dataSource = container.read(alertRemoteDataSourceProvider);
      expect(() => dataSource.updateAlert(tAlerta), throwsA(isA<AlertNotFoundException>()));
    });
  });

  group('watchAllAlerts', () {
    test('deve emitir lista de alertas quando o snapshot mudar', () async {
      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDocSnap1 = MockQueryDocumentSnapshot();
      final map1 = _mapFromAlert(tAlerta);

      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(() => mockQuerySnapshot.docs).thenReturn([mockDocSnap1]);
      when(() => mockDocSnap1.data()).thenReturn(map1);
      when(() => mockDocSnap1.id).thenReturn(tAlerta.uid);

      final dataSource = container.read(alertRemoteDataSourceProvider);
      final stream = dataSource.watchAllAlerts();

      final events = await stream.first;
      expect(events, isA<List<AlertModel>>());
      expect(events.length, equals(1));
      expect(events[0].titulo, equals(tAlerta.titulo));

      verify(() => firestore.collection('alerts')).called(1);
      verify(() => mockCollection.snapshots()).called(1);
    });

    test('deve lançar UnknownDataSourceException quando snapshots falhar', () async {
      when(() => firestore.collection('alerts')).thenThrow(Exception('Stream error'));
      final dataSource = container.read(alertRemoteDataSourceProvider);
      expect(() => dataSource.watchAllAlerts().first, throwsA(isA<UnknownDataSourceException>()));
    });

    test('deve emitir lista vazia quando stream retorna snapshot sem docs', () async {
      final mockQuerySnapshot = MockQuerySnapshot();

      when(() => firestore.collection('alerts')).thenReturn(mockCollection);
      when(() => mockCollection.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(() => mockQuerySnapshot.docs).thenReturn([]);

      final dataSource = container.read(alertRemoteDataSourceProvider);
      final result = await dataSource.watchAllAlerts().first;

      expect(result, isEmpty);
    });
  });
}

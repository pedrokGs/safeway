import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/common/exceptions/network_request_failed_exception.dart';
import 'package:safeway/common/exceptions/unauthorized_exception.dart';
import 'package:safeway/core/di/alert_providers.dart';
import 'package:safeway/features/alerts/data/datasources/alert_remote_datasource.dart';
import 'package:safeway/features/alerts/data/models/alert_model.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/domain/enums/alert_type.dart';
import 'package:safeway/features/alerts/domain/exceptions/alert_not_found_exception.dart';

class MockAlertDataSource extends Mock implements AlertRemoteDataSource {}

void main(){
  late MockAlertDataSource dataSource;
  late ProviderContainer container;

  setUp(() {
    dataSource = MockAlertDataSource();
    container = ProviderContainer(
        overrides: [
          alertRemoteDataSourceProvider.overrideWithValue(dataSource)
        ]
    );
    addTearDown(container.dispose);
  },);

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

  setUpAll(() {
    registerFallbackValue(tAlerta);
  },);

  group('getAllAlerts', () {
    test('should return list with alerts on success', () async {
      when(() => dataSource.getAllAlerts()).thenAnswer((_) async => [tAlerta, tAlerta2],);

      final repository = container.read(alertRepositoryProvider);

      final result = await repository.getAllAlerts();

      expect(result, equals([tAlerta.toEntity(), tAlerta2.toEntity()]));
      verify(() => dataSource.getAllAlerts()).called(1);
    },);

    test('should return empty list when there is no alert', () async {
      when(() => dataSource.getAllAlerts()).thenAnswer((_) async => []);

      final repository = container.read(alertRepositoryProvider);
      final result = await repository.getAllAlerts();

      await expectLater(result, equals([]));
      verify(()=>dataSource.getAllAlerts()).called(1);
    },);

    test('should return UnauthenticatedException when user is not authenticated', () async {
      when(() => dataSource.getAllAlerts()).thenThrow(UnauthenticatedException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(repository.getAllAlerts(), throwsA(isA<UnauthenticatedException>()));
      verify(() => dataSource.getAllAlerts()).called(1);
      },);

    test('should return NetworkRequestFailedException when user is not connected to the internet', () async {
      when(() => dataSource.getAllAlerts()).thenThrow(NetworkRequestFailedException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(repository.getAllAlerts(), throwsA(isA<NetworkRequestFailedException>()));
      verify(() => dataSource.getAllAlerts()).called(1);
    },);
  },);

  group('getAlertsByType', () {
    test('should return only alerts with the solicited type', () async {
      when(() => dataSource.getAlertsByType(AlertType.incendio)).thenAnswer((_) async => [tAlerta],);

      final repository = container.read(alertRepositoryProvider);
      final results = await repository.getAlertsByType(AlertType.incendio);

      expect(results.every((element) => element.tipo == AlertType.incendio,), true);
      verify(() => dataSource.getAlertsByType(AlertType.incendio)).called(1);
    },);
    
    test('should return empty list when there is no alert matching the specified type', () async {
      when(() => dataSource.getAlertsByType(AlertType.outro)).thenAnswer((_) async => [],);
      
      final repository = container.read(alertRepositoryProvider);
      final result = await repository.getAlertsByType(AlertType.outro);

      await expectLater(result, equals([]));
      verify(()=>dataSource.getAlertsByType(AlertType.outro)).called(1);
    },);

    test('should return UnauthenticatedException when user is not authenticated', () async {
      when(() => dataSource.getAlertsByType(AlertType.acidentes)).thenThrow(UnauthenticatedException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(repository.getAlertsByType(AlertType.acidentes), throwsA(isA<UnauthenticatedException>()));
      verify(() => dataSource.getAlertsByType(AlertType.acidentes)).called(1);
    },);

    test('should return NetworkRequestFailedException when user is not connected to the internet', () async {
      when(() => dataSource.getAlertsByType(AlertType.acidentes)).thenThrow(NetworkRequestFailedException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(repository.getAlertsByType(AlertType.acidentes), throwsA(isA<NetworkRequestFailedException>()));
      verify(() => dataSource.getAlertsByType(AlertType.acidentes)).called(1);
    },);
  },);

  group('getAlertsByRisk', () {
    test('should return only alerts with the solicited risk', () async {
      when(() => dataSource.getAlertsByRisk(AlertRisk.alto)).thenAnswer((_) async => [tAlerta],);

      final repository = container.read(alertRepositoryProvider);
      final results = await repository.getAlertsByRisk(AlertRisk.alto);

      expect(results.every((element) => element.risco == AlertRisk.alto,), true);
      verify(() => dataSource.getAlertsByRisk(AlertRisk.alto)).called(1);
    },);

    test('should return empty list when there is no alert matching the specified type', () async {
      when(() => dataSource.getAlertsByRisk(AlertRisk.critico)).thenAnswer((_) async => [],);

      final repository = container.read(alertRepositoryProvider);
      final result = await repository.getAlertsByRisk(AlertRisk.critico);

      await expectLater(result, equals([]));
      verify(()=>dataSource.getAlertsByRisk(AlertRisk.critico)).called(1);
    },);

    test('should return UnauthenticatedException when user is not authenticated', () async {
      when(() => dataSource.getAlertsByRisk(AlertRisk.baixo)).thenThrow(UnauthenticatedException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(repository.getAlertsByRisk(AlertRisk.baixo), throwsA(isA<UnauthenticatedException>()));
      verify(() => dataSource.getAlertsByRisk(AlertRisk.baixo)).called(1);
    },);

    test('should return NetworkRequestFailedException when user is not connected to the internet', () async {
      when(() => dataSource.getAlertsByRisk(AlertRisk.baixo)).thenThrow(NetworkRequestFailedException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(repository.getAlertsByRisk(AlertRisk.baixo), throwsA(isA<NetworkRequestFailedException>()));
      verify(() => dataSource.getAlertsByRisk(AlertRisk.baixo)).called(1);
    },);
  },);

  group('deleteAlertById', () {
    test('should remove the alert with correspondent ID', () async {
      when(() => dataSource.deleteAlertById(any())).thenAnswer((_) async => {},);

      final repository = container.read(alertRepositoryProvider);

      await repository.deleteAlertById('123');

      verify(() => dataSource.deleteAlertById('123')).called(1);
    },);

    test("should throw AlertNotFoundException when id doesn't correspond to any", () async {
      when(() => dataSource.deleteAlertById(any())).thenThrow(AlertNotFoundException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(repository.deleteAlertById('123'), throwsA(isA<AlertNotFoundException>()));
      verify(() => dataSource.deleteAlertById('123')).called(1);
    },);

    test('should return UnauthenticatedException when user is not authenticated', () async {
      when(() => dataSource.deleteAlertById(any())).thenThrow(UnauthenticatedException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(repository.deleteAlertById('123'), throwsA(isA<UnauthenticatedException>()));
      verify(() => dataSource.deleteAlertById('123')).called(1);
    },);

    test('should return NetworkRequestFailedException when user is not connected to the internet', () async {
      when(() => dataSource.deleteAlertById(any())).thenThrow(NetworkRequestFailedException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(repository.deleteAlertById('123'), throwsA(isA<NetworkRequestFailedException>()));
      verify(() => dataSource.deleteAlertById('123')).called(1);
    },);
  },);
  group('updateAlert', () {
    test('should update and return the updated alert on success', () async {
      when(() => dataSource.updateAlert(any()))
          .thenAnswer((_) async => tAlerta.copyWith(titulo: 'Atualizado'));

      final repository = container.read(alertRepositoryProvider);
      final updatedEntity = await repository.updateAlert(tAlerta.toEntity());

      expect(updatedEntity.titulo, equals('Atualizado'));
      verify(() => dataSource.updateAlert(any())).called(1);
    });

    test('should throw AlertNotFoundException when alert does not exist', () async {
      when(() => dataSource.updateAlert(any())).thenThrow(AlertNotFoundException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(
        repository.updateAlert(tAlerta.toEntity()),
        throwsA(isA<AlertNotFoundException>()),
      );
      verify(() => dataSource.updateAlert(any())).called(1);
    });

    test('should throw UnauthenticatedException when user is not authenticated', () async {
      when(() => dataSource.updateAlert(any())).thenThrow(UnauthenticatedException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(
        repository.updateAlert(tAlerta.toEntity()),
        throwsA(isA<UnauthenticatedException>()),
      );
      verify(() => dataSource.updateAlert(any())).called(1);
    });

    test('should throw NetworkRequestFailedException when not connected to internet', () async {
      when(() => dataSource.updateAlert(any())).thenThrow(NetworkRequestFailedException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(
        repository.updateAlert(tAlerta.toEntity()),
        throwsA(isA<NetworkRequestFailedException>()),
      );
      verify(() => dataSource.updateAlert(any())).called(1);
    });
  });

  group('createAlert', () {
    test('should create and return the new alert on success', () async {
      when(() => dataSource.createAlert(tAlerta)).thenAnswer((_) async => tAlerta);

      final repository = container.read(alertRepositoryProvider);
      final result = await repository.createAlert(tAlerta.toEntity());

      expect(result, equals(tAlerta.toEntity()));
      verify(() => dataSource.createAlert(tAlerta)).called(1);
    });

    test('should throw UnauthenticatedException when user is not authenticated', () async {
      when(() => dataSource.createAlert(any())).thenThrow(UnauthenticatedException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(
        repository.createAlert(tAlerta.toEntity()),
        throwsA(isA<UnauthenticatedException>()),
      );
      verify(() => dataSource.createAlert(any())).called(1);
    });

    test('should throw NetworkRequestFailedException when not connected to internet', () async {
      when(() => dataSource.createAlert(tAlerta)).thenThrow(NetworkRequestFailedException());

      final repository = container.read(alertRepositoryProvider);

      await expectLater(
        repository.createAlert(tAlerta.toEntity()),
        throwsA(isA<NetworkRequestFailedException>()),
      );
      verify(() => dataSource.createAlert(tAlerta)).called(1);
    });
  });

  group('watchAllAlerts', () {
    test('should emit alert list when data changes', () async {
      final alertStream = Stream.value([tAlerta, tAlerta2]);
      when(() => dataSource.watchAllAlerts()).thenAnswer((_) => alertStream);

      final repository = container.read(alertRepositoryProvider);
      final resultStream = repository.watchAllAlerts();

      await expectLater(
        resultStream,
        emits([tAlerta.toEntity(), tAlerta2.toEntity()]),
      );
      verify(() => dataSource.watchAllAlerts()).called(1);
    });

    test('should emit empty list when there are no alerts', () async {
      final alertStream = Stream<List<AlertModel>>.value([]);
      when(() => dataSource.watchAllAlerts()).thenAnswer((_) => alertStream);

      final repository = container.read(alertRepositoryProvider);
      final resultStream = repository.watchAllAlerts();

      await expectLater(resultStream, emits([]));
      verify(() => dataSource.watchAllAlerts()).called(1);
    });

    test('should throw UnauthenticatedException when user is not authenticated', () async {
      when(() => dataSource.watchAllAlerts()).thenThrow(UnauthenticatedException());

      final repository = container.read(alertRepositoryProvider);

      expect(
            () => repository.watchAllAlerts(),
        throwsA(isA<UnauthenticatedException>()),
      );
      verify(() => dataSource.watchAllAlerts()).called(1);
    });

    test('should throw NetworkRequestFailedException when network fails', () async {
      when(() => dataSource.watchAllAlerts()).thenThrow(NetworkRequestFailedException());

      final repository = container.read(alertRepositoryProvider);

      expect(
            () => repository.watchAllAlerts(),
        throwsA(isA<NetworkRequestFailedException>()),
      );
      verify(() => dataSource.watchAllAlerts()).called(1);
    });
  });
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/common/exceptions/invalid_argument_exception.dart';
import 'package:safeway/core/di/alert_providers.dart';
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/domain/enums/alert_type.dart';
import 'package:safeway/features/alerts/domain/exceptions/alert_already_exists_exception.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class MockAlertRepository extends Mock implements AlertRepository {}

void main() {
  late MockAlertRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockAlertRepository();
    container = ProviderContainer(
      overrides: [alertRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  final tAlerta = AlertEntity(
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

  setUpAll(() {
    registerFallbackValue(tAlerta);
  });

  // Deve retornar o valor correto quando enviado com valores válidos :)
  test(
    'should call Repository with correct arguments and receive correct results',
    () async {
      when(
        () => repository.createAlert(any()),
      ).thenAnswer((_) async => tAlerta.copyWith(uid: "123"));

      final useCase = container.read(createAlertUseCaseProvider);

      final results = await useCase.call(tAlerta);

      expect(results, tAlerta.copyWith(uid: '123'));
      verify(() => repository.createAlert(tAlerta)).called(1);
    },
  );

  // Quando alerta já existe no banco de dados, lança uma exception
  test(
    'should return AlertAlreadyExistsException when repository throws AlertAlreadyExistsException',
    () async {
      when(
        () => repository.createAlert(any()),
      ).thenThrow(AlertAlreadyExistsException());

      final useCase = container.read(createAlertUseCaseProvider);

      await expectLater(
        useCase.call(tAlerta),
        throwsA(isA<AlertAlreadyExistsException>()),
      );
      verify(() => repository.createAlert(tAlerta)).called(1);
    },
  );

  // garante que ninguém vai abusar do limite de caractéres
  test(
    'should throw InvalidArgumentException when a field is above its limit',
    () async {
      final useCase = container.read(createAlertUseCaseProvider);

      final illegalAlerta = tAlerta.copyWith(
        titulo:
            'a' * 300,
      );

      await expectLater(
        useCase.call(illegalAlerta),
        throwsA(isA<InvalidArgumentException>()),
      );
      verifyNever(() => repository.createAlert(illegalAlerta));
    },
  );

  test('should throw InvalidArgumentException when date is invalid', () async {
    final useCase = container.read(createAlertUseCaseProvider);

    final illegalAlerta = tAlerta.copyWith(data: DateTime.utc(2030));

    await expectLater(
      useCase.call(illegalAlerta),
      throwsA(isA<InvalidArgumentException>()),
    );
    verifyNever(() => repository.createAlert(illegalAlerta));
  },);

  test('should throw InvalidArgumentException when latitude/longitude is not valid', () async {
    final useCase = container.read(createAlertUseCaseProvider);

    final illegalAlerta = tAlerta.copyWith(latitude: 91);

    await expectLater(
      useCase.call(illegalAlerta),
      throwsA(isA<InvalidArgumentException>()),
    );
    verifyNever(() => repository.createAlert(illegalAlerta));
  },);
}

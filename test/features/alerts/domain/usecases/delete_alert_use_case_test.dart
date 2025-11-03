import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/common/exceptions/invalid_argument_exception.dart';
import 'package:safeway/core/di/alert_providers.dart';
import 'package:safeway/features/alerts/domain/exceptions/alert_not_found_exception.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class MockAlertRepository extends Mock implements AlertRepository {}

void main(){
  late MockAlertRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = MockAlertRepository();
    container = ProviderContainer(
        overrides: [
          alertRepositoryProvider.overrideWithValue(repository)
        ]
    );
    addTearDown(container.dispose);
  },);

  test('should call repository and pass correct arguments when id is valid', () async {
    when(() => repository.deleteAlertById(any())).thenAnswer((_) async => {},);

    final useCase = container.read(deleteAlertUseCaseProvider);

    await useCase.call('1');

    verify(() => repository.deleteAlertById('1')).called(1);
  },);

  test('should throw an InvalidArgumentException when id is malformed', () async {
    final useCase = container.read(deleteAlertUseCaseProvider);

    await expectLater(useCase.call(''), throwsA(isA<InvalidArgumentException>()));
    verifyNever(() => repository.deleteAlertById(''));
  },);

  test('should return an AlertNotFoundException when alert was not found by repo', () async {
    when(() => repository.deleteAlertById(any())).thenThrow(AlertNotFoundException());

    final useCase = container.read(deleteAlertUseCaseProvider);

    await expectLater(useCase.call('1'), throwsA(isA<AlertNotFoundException>()));
    verify(() => repository.deleteAlertById('1')).called(1);
  },);
}
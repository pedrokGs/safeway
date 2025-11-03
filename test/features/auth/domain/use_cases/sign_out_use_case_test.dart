import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/common/exceptions/data_source_exception.dart';
import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main(){
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer providerContainer;

  setUp(() {
    mockAuthRepository = MockAuthRepository();

    providerContainer = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepository),
    ]);
    addTearDown(providerContainer.dispose);
  },);

  test('should complete when repository succeeds', () async {
    when(() => mockAuthRepository.signOut(),).thenAnswer((_) async => true,);

    final signOutUseCase = providerContainer.read(signOutUseCaseProvider);

    await signOutUseCase.call();

    verify(() => mockAuthRepository.signOut()).called(1);
  },);

  test('should return an exception when repository throws an DatasourceException', () async {
    when(() => mockAuthRepository.signOut()).thenThrow(DataSourceException('erro teste'));

    final signOutUseCase = providerContainer.read(signOutUseCaseProvider);

    expectLater(signOutUseCase.call(), throwsA(isA<DataSourceException>()));
    verify(() => mockAuthRepository.signOut()).called(1);
  },);
}
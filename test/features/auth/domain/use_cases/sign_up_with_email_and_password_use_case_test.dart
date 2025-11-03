import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/common/exceptions/data_source_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late ProviderContainer providerContainer;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();

    providerContainer = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );
    addTearDown(providerContainer.dispose);
  });

  final String tId = '123';

  test('should call signUpWithEmailAndPassword on repository with correct values and returns correct value', () async {
    when(
          () => mockAuthRepository.signUpWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => tId);

    final signUpUseCase = providerContainer.read(signUpWithEmailAndPasswordUseCaseProvider);

    final result = await signUpUseCase.call(email: 'test@gmail.com', password: 'Password123');

    expect(result, tId);
    verify(() => mockAuthRepository.signUpWithEmailAndPassword(email: 'test@gmail.com', password: 'Password123')).called(1);
  });

  test('should return exception when repository call fails', () async {
    when(() => mockAuthRepository.signUpWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')),).thenThrow(DataSourceException('test error'));
    final signUpUseCase = providerContainer.read(signUpWithEmailAndPasswordUseCaseProvider);

    expectLater(() => signUpUseCase.call(email: 'test@gmail.com', password: 'Password123'), throwsA(isA<DataSourceException>()));
    verify(() => mockAuthRepository.signUpWithEmailAndPassword(email: 'test@gmail.com', password: 'Password123'),).called(1);
  },);

  test('should throw InvalidCredentialsException when email is invalid', () async {
    final signUpUseCase = providerContainer.read(signUpWithEmailAndPasswordUseCaseProvider);

    expect(() => signUpUseCase.call(email: 'invalidEmail', password: 'Password123'), throwsA(isA<InvalidCredentialsException>()));
    verifyNever(() => mockAuthRepository.signUpWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')));
  },);

  test('should throw InvalidCredentialsException when password is invalid', () async {
    final signUpUseCase = providerContainer.read(signUpWithEmailAndPasswordUseCaseProvider);

    expect(() => signUpUseCase.call(email: 'test@gmail.com', password: '123'), throwsA(isA<InvalidCredentialsException>()));
    verifyNever(() => mockAuthRepository.signUpWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')));
  },);
}

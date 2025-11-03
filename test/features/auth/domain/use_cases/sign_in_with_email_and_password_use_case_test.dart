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

  test('should call signInWithEmailAndPassword on repository with correct values and returns correct value', () async {
    when(
      () => mockAuthRepository.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => tId);

    final signInUseCase = providerContainer.read(signInWithEmailAndPasswordUseCaseProvider);

    final result = await signInUseCase.call(email: 'test@gmail.com', password: 'Password123');

    expect(result, tId);
    verify(() => mockAuthRepository.signInWithEmailAndPassword(email: 'test@gmail.com', password: 'Password123')).called(1);
  });

  test('should return exception when repository call fails', () async {
    when(() => mockAuthRepository.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')),).thenThrow(DataSourceException('test error'));
    final signInUseCase = providerContainer.read(signInWithEmailAndPasswordUseCaseProvider);

    expectLater(() => signInUseCase.call(email: 'test@gmail.com', password: 'Password123'), throwsA(isA<DataSourceException>()));
    verify(() => mockAuthRepository.signInWithEmailAndPassword(email: 'test@gmail.com', password: 'Password123'),).called(1);
  },);

  test('should throw InvalidCredentialsException when email is invalid', () async {
    final signInUseCase = providerContainer.read(signInWithEmailAndPasswordUseCaseProvider);

    expect(() => signInUseCase.call(email: 'invalidEmail', password: 'Password123'), throwsA(isA<InvalidCredentialsException>()));
    verifyNever(() => mockAuthRepository.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')));
  },);

  test('should throw InvalidCredentialsException when password is invalid', () async {
    final signInUseCase = providerContainer.read(signInWithEmailAndPasswordUseCaseProvider);

    expect(() => signInUseCase.call(email: 'test@gmail.com', password: '123'), throwsA(isA<InvalidCredentialsException>()));
    verifyNever(() => mockAuthRepository.signInWithEmailAndPassword(email: any(named: 'email'), password: any(named: 'password')));
  },);
}

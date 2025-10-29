import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/domain/exceptions/data_source_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
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

  test('should return true when repository returns true', () async {
    when(() => mockAuthRepository.sendResetPasswordEmail(email: any(named: 'email')),).thenAnswer((_) async => true,);

    final sendResetPasswordEmailUseCase = providerContainer.read(sendResetPasswordEmailUseCaseProvider);

    final result = await sendResetPasswordEmailUseCase.call(email: "test@gmail.com");

    expect(result, true);
    verify(() => mockAuthRepository.sendResetPasswordEmail(email: "test@gmail.com")).called(1);
  },);

  test('should return false when repository returns false', () async {
    when(() => mockAuthRepository.sendResetPasswordEmail(email: any(named: 'email'))).thenAnswer((_) async => false);

    final sendResetPasswordUseCase = providerContainer.read(sendResetPasswordEmailUseCaseProvider);

    final result = await sendResetPasswordUseCase.call(email: "test@gmail.com");

    expect(result, false);
    verify(() => mockAuthRepository.sendResetPasswordEmail(email: "test@gmail.com"),);
  },);

  test('should return an exception when repository throws an DatasourceException', () async {
    when(() => mockAuthRepository.sendResetPasswordEmail(email: any(named: 'email'))).thenThrow(DataSourceException('erro teste'));
    
    final sendResetPasswordUseCase = providerContainer.read(sendResetPasswordEmailUseCaseProvider);
    
    expectLater(sendResetPasswordUseCase.call(email: 'test@gmail.com'), throwsA(isA<DataSourceException>()));
    verify(() => mockAuthRepository.sendResetPasswordEmail(email: 'test@gmail.com')).called(1);
  },);

  test('should throw InvalidCredentialsException when email is invalid', () {
    final sendResetPasswordUseCase = providerContainer.read(sendResetPasswordEmailUseCaseProvider);

    expectLater(sendResetPasswordUseCase.call(email: 'invalidemail'), throwsA(isA<InvalidCredentialsException>()));
    verifyNever(() => mockAuthRepository.sendResetPasswordEmail(email: any(named: 'email')));
    },);
}
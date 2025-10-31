import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/domain/exceptions/data_source_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/user_not_found_exception.dart';
import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer providerContainer;

  setUp(() {
    mockAuthRepository = MockAuthRepository();

    providerContainer = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(mockAuthRepository)],
    );
    addTearDown(providerContainer.dispose);
  });

  test(
    'should return nothing if operation succeds, and should pass correct parameters to repository',
    () async {
      when(
        () => mockAuthRepository.sendResetPasswordEmail(
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => {});

      final sendResetPasswordEmailUseCase = providerContainer.read(
        sendResetPasswordEmailUseCaseProvider,
      );

      await sendResetPasswordEmailUseCase.call(email: "test@gmail.com");

      verify(
        () =>
            mockAuthRepository.sendResetPasswordEmail(email: "test@gmail.com"),
      ).called(1);
    },
  );

  test(
    'should return an exception when repository throws an DatasourceException',
    () async {
      when(
        () => mockAuthRepository.sendResetPasswordEmail(
          email: any(named: 'email'),
        ),
      ).thenThrow(UserNotFoundException());

      final sendResetPasswordUseCase = providerContainer.read(
        sendResetPasswordEmailUseCaseProvider,
      );

      expectLater(
        sendResetPasswordUseCase.call(email: 'test@gmail.com'),
        throwsA(isA<DataSourceException>()),
      );
      verify(
        () =>
            mockAuthRepository.sendResetPasswordEmail(email: 'test@gmail.com'),
      ).called(1);
    },
  );

  test('should throw InvalidCredentialsException when email is invalid', () {
    final sendResetPasswordUseCase = providerContainer.read(
      sendResetPasswordEmailUseCaseProvider,
    );

    expectLater(
      sendResetPasswordUseCase.call(email: 'invalidemail'),
      throwsA(isA<InvalidCredentialsException>()),
    );
    verifyNever(
      () =>
          mockAuthRepository.sendResetPasswordEmail(email: any(named: 'email')),
    );
  });
}

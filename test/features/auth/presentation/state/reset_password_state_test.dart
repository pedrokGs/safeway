
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/user_not_found_exception.dart';
import 'package:safeway/features/auth/domain/use_cases/send_reset_password_email_use_case.dart';
import 'package:safeway/features/auth/presentation/state/password_reset_state.dart';

class MockSendResetPasswordEmailUseCase extends Mock
    implements SendResetPasswordWithEmailUseCase {}

void main() {
  late MockSendResetPasswordEmailUseCase mockSendResetPasswordEmailUseCase;
  late ProviderContainer providerContainer;

  setUp(() {
    mockSendResetPasswordEmailUseCase = MockSendResetPasswordEmailUseCase();
    providerContainer = ProviderContainer(
      overrides: [
        sendResetPasswordEmailUseCaseProvider.overrideWithValue(
          mockSendResetPasswordEmailUseCase,
        ),
      ],
    );
    addTearDown(providerContainer.dispose);
  });

  final String tEmail = 'email@email.com';

  test(
    'should return an SignInState with success = true when operation is successful',
        () async {
      when(
            () => mockSendResetPasswordEmailUseCase.call(
          email: any(named: 'email'),
        ),
      ).thenAnswer((_) async => {});

      final resetPasswordNotifier = providerContainer.read(
        passwordResetStateNotifierProvider.notifier,
      );

      await resetPasswordNotifier.sendResetPassword(email: tEmail);

      final resetPasswordState = providerContainer.read(passwordResetStateNotifierProvider);

      final expected = PasswordResetState(success: true);

      expect(resetPasswordState, equals(expected));
      verify(
            () => mockSendResetPasswordEmailUseCase.call(email: tEmail),
      ).called(1);
    },
  );

  test(
    'should return a PasswordResetState with error message "Verifique o email" when use case throws InvalidCredentialsException',
        () async {
      when(
            () => mockSendResetPasswordEmailUseCase.call(
          email: any(named: 'email'),
        ),
      ).thenThrow(InvalidCredentialsException());

      final passwordResetNotifier = providerContainer.read(
        passwordResetStateNotifierProvider.notifier,
      );

      await passwordResetNotifier.sendResetPassword(email: 'email-invalido');

      final signInState = providerContainer.read(passwordResetStateNotifierProvider);

      final expected = PasswordResetState(
        errorMessage: 'Verifique o email',
      );

      expect(signInState, equals(expected));
      verify(
            () => mockSendResetPasswordEmailUseCase.call(
          email: 'email-invalido',
        ),
      ).called(1);
    },
  );

  test(
    'should return an SignInState with error message "Usuário não encontrado" when use case returns UserNotFoundException',
        () async {
      when(
            () => mockSendResetPasswordEmailUseCase.call(
          email: any(named: 'email'),
        ),
      ).thenThrow(UserNotFoundException());

      final passwordResetNotifier = providerContainer.read(
        passwordResetStateNotifierProvider.notifier,
      );

      await passwordResetNotifier.sendResetPassword(email: tEmail);

      final passwordResetState = providerContainer.read(passwordResetStateNotifierProvider);

      final expected = PasswordResetState(errorMessage: "Usuário não encontrado");

      expect(passwordResetState, equals(expected));
      verify(
            () => mockSendResetPasswordEmailUseCase.call(email: tEmail),
      ).called(1);
    },
  );

  test(
    'should return an SignInState with error message containing "Erro desconhecido:" when use case returns an Unknown Error',
        () async {
      when(
            () => mockSendResetPasswordEmailUseCase.call(
          email: any(named: 'email'),
        ),
      ).thenThrow(Exception());

      final passwordResetNotifier = providerContainer.read(
        passwordResetStateNotifierProvider.notifier,
      );

      await passwordResetNotifier.sendResetPassword(email: tEmail);

      final passwordResetState = providerContainer.read(passwordResetStateNotifierProvider);

      expect(passwordResetState.errorMessage, contains("Erro desconhecido:"));
      verify(
            () => mockSendResetPasswordEmailUseCase.call(email: tEmail),
      ).called(1);
    },
  );

}


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/domain/exceptions/email_already_in_use_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/google_sign_in_cancelled_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/user_not_found_exception.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_up_with_email_and_password_use_case.dart';
import 'package:safeway/features/auth/presentation/state/sign_up_state.dart';

class MockSignUpUseCase extends Mock
    implements SignUpWithEmailAndPasswordUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

void main() {
  late MockSignUpUseCase mockSignUpUseCase;
  late MockSignInWithGoogleUseCase mockSignInWithGoogleUseCase;
  late ProviderContainer providerContainer;

  setUp(() {
    mockSignInWithGoogleUseCase = MockSignInWithGoogleUseCase();
    mockSignUpUseCase = MockSignUpUseCase();

    providerContainer = ProviderContainer(
      overrides: [
        signInWithGoogleUseCaseProvider.overrideWithValue(
          mockSignInWithGoogleUseCase,
        ),
        signUpWithEmailAndPasswordUseCaseProvider.overrideWithValue(
          mockSignUpUseCase,
        ),
      ],
    );

    addTearDown(providerContainer.dispose);
  });

  final String tEmail = 'email@email.com';
  final String tPassword = 'Password123';
  final String tId = '123';

  group('signUpWithEmailAndPassword', () {
    test(
      'should return an SignUpState with success = true when operation is successful',
          () async {
        when(
              () => mockSignUpUseCase.call(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => tId);

        final signUpNotifier = providerContainer.read(
          signUpStateNotifierProvider.notifier,
        );

        await signUpNotifier.signUp(tEmail, tPassword);

        final signUpState = providerContainer.read(signUpStateNotifierProvider);

        final expected = SignUpState(success: true, isLoading: false);

        expect(signUpState, equals(expected));
        verify(
              () => mockSignUpUseCase.call(email: tEmail, password: tPassword),
        ).called(1);
      },
    );

    test(
      'should return an SignUpState with error message "Credenciais inválidas, verifique a senha e o email" when use case throws InvalidCredentialsException',
          () async {
        when(
              () => mockSignUpUseCase.call(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(InvalidCredentialsException());

        final signUpNotifier = providerContainer.read(
          signUpStateNotifierProvider.notifier,
        );

        await signUpNotifier.signUp('email-invalido', tPassword);

        final signUpState = providerContainer.read(signUpStateNotifierProvider);

        final expected = SignUpState(
          errorMessage: 'Credenciais inválidas, verifique a senha e o email',
        );

        expect(signUpState, equals(expected));
        verify(
              () => mockSignUpUseCase.call(
            email: 'email-invalido',
            password: tPassword,
          ),
        ).called(1);
      },
    );

    test(
      'should return an SignUpState with error message "Email já está em uso" when use case returns EmailAlreadyInUseException',
          () async {
        when(
              () => mockSignUpUseCase.call(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(EmailAlreadyInUseException());

        final signUpNotifier = providerContainer.read(
          signUpStateNotifierProvider.notifier,
        );

        await signUpNotifier.signUp(tEmail, tPassword);

        final signUpState = providerContainer.read(signUpStateNotifierProvider);

        final expected = SignUpState(errorMessage: "Email já está em uso");

        expect(signUpState, equals(expected));
        verify(
              () => mockSignUpUseCase.call(email: tEmail, password: tPassword),
        ).called(1);
      },
    );

    test(
      'should return an SignUpState with error message containing "Erro desconhecido:" when use case returns an Unknown Error',
          () async {
        when(
              () => mockSignUpUseCase.call(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception());

        final signUpNotifier = providerContainer.read(
          signUpStateNotifierProvider.notifier,
        );

        await signUpNotifier.signUp(tEmail, tPassword);

        final signUpState = providerContainer.read(signUpStateNotifierProvider);

        expect(signUpState.errorMessage, contains("Erro desconhecido:"));
        verify(
              () => mockSignUpUseCase.call(email: tEmail, password: tPassword),
        ).called(1);
      },
    );
  });

  group('signInWithGoogle', () {
    test(
      'should return an SignUpState with success = true when operation is successful',
          () async {
        when(
              () => mockSignInWithGoogleUseCase.call(),
        ).thenAnswer((_) async => tId);

        final signUpNotifier = providerContainer.read(
          signUpStateNotifierProvider.notifier,
        );

        await signUpNotifier.signInWithGoogle();

        final signUpState = providerContainer.read(signUpStateNotifierProvider);

        final expected = SignUpState(success: true, isLoading: false);

        expect(signUpState, equals(expected));
        verify(() => mockSignInWithGoogleUseCase.call()).called(1);
      },
    );

    test(
      'should return an SignUpState with error message "A entrada foi cancelada" when use case throws GoogleSignUpCancelledException',
          () async {
        when(
              () => mockSignInWithGoogleUseCase.call(),
        ).thenThrow(GoogleSignInCancelledException());

        final signUpNotifier = providerContainer.read(
          signUpStateNotifierProvider.notifier,
        );

        await signUpNotifier.signInWithGoogle();

        final signUpState = providerContainer.read(signUpStateNotifierProvider);

        final expected = SignUpState(errorMessage: 'A entrada foi cancelada');

        expect(signUpState, equals(expected));
        verify(() => mockSignInWithGoogleUseCase.call()).called(1);
      },
    );

    test(
      'should return an SignUpState with error message "Credenciais inválidas" when use case throws InvalidCredentialsException',
          () async {
        when(
              () => mockSignInWithGoogleUseCase.call(),
        ).thenThrow(InvalidCredentialsException());

        final signUpNotifier = providerContainer.read(
          signUpStateNotifierProvider.notifier,
        );

        await signUpNotifier.signInWithGoogle();

        final signUpState = providerContainer.read(signUpStateNotifierProvider);

        final expected = SignUpState(errorMessage: 'Credenciais inválidas');

        expect(signUpState, equals(expected));
        verify(() => mockSignInWithGoogleUseCase.call()).called(1);
      },
    );
  });
}

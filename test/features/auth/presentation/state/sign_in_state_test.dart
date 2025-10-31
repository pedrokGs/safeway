import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/domain/exceptions/google_sign_in_cancelled_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/user_not_found_exception.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:safeway/features/auth/presentation/state/sign_in_state.dart';

class MockSignInUseCase extends Mock
    implements SignInWithEmailAndPasswordUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

void main() {
  late MockSignInUseCase mockSignInUseCase;
  late MockSignInWithGoogleUseCase mockSignInWithGoogleUseCase;
  late ProviderContainer providerContainer;

  setUp(() {
    mockSignInWithGoogleUseCase = MockSignInWithGoogleUseCase();
    mockSignInUseCase = MockSignInUseCase();

    providerContainer = ProviderContainer(
      overrides: [
        signInWithGoogleUseCaseProvider.overrideWithValue(
          mockSignInWithGoogleUseCase,
        ),
        signInWithEmailAndPasswordUseCaseProvider.overrideWithValue(
          mockSignInUseCase,
        ),
      ],
    );

    addTearDown(providerContainer.dispose);
  });

  final String tEmail = 'email@email.com';
  final String tPassword = 'Password123';
  final String tId = '123';

  group('signInWithEmailAndPassword', () {
    test(
      'should return an SignInState with success = true when operation is successful',
      () async {
        when(
          () => mockSignInUseCase.call(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => tId);

        final signInNotifier = providerContainer.read(
          signInStateNotifierProvider.notifier,
        );

        await signInNotifier.signIn(tEmail, tPassword);

        final signInState = providerContainer.read(signInStateNotifierProvider);

        final expected = SignInState(success: true, isLoading: false);

        expect(signInState, equals(expected));
        verify(
          () => mockSignInUseCase.call(email: tEmail, password: tPassword),
        ).called(1);
      },
    );

    test(
      'should return an SignInState with error message "Credenciais inválidas, verifique a senha e o email" when use case throws InvalidCredentialsException',
      () async {
        when(
          () => mockSignInUseCase.call(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(InvalidCredentialsException());

        final signInNotifier = providerContainer.read(
          signInStateNotifierProvider.notifier,
        );

        await signInNotifier.signIn('email-invalido', tPassword);

        final signInState = providerContainer.read(signInStateNotifierProvider);

        final expected = SignInState(
          errorMessage: 'Credenciais inválidas, verifique a senha e o email',
        );

        expect(signInState, equals(expected));
        verify(
          () => mockSignInUseCase.call(
            email: 'email-invalido',
            password: tPassword,
          ),
        ).called(1);
      },
    );

    test(
      'should return an SignInState with error message "Usuário não encontrado" when use case returns UserNotFoundException',
      () async {
        when(
          () => mockSignInUseCase.call(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(UserNotFoundException());

        final signInNotifier = providerContainer.read(
          signInStateNotifierProvider.notifier,
        );

        await signInNotifier.signIn(tEmail, tPassword);

        final signInState = providerContainer.read(signInStateNotifierProvider);

        final expected = SignInState(errorMessage: "Usuário não encontrado");

        expect(signInState, equals(expected));
        verify(
          () => mockSignInUseCase.call(email: tEmail, password: tPassword),
        ).called(1);
      },
    );

    test(
      'should return an SignInState with error message containing "Erro desconhecido:" when use case returns an Unknown Error',
      () async {
        when(
          () => mockSignInUseCase.call(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception());

        final signInNotifier = providerContainer.read(
          signInStateNotifierProvider.notifier,
        );

        await signInNotifier.signIn(tEmail, tPassword);

        final signInState = providerContainer.read(signInStateNotifierProvider);

        expect(signInState.errorMessage, contains("Erro desconhecido:"));
        verify(
          () => mockSignInUseCase.call(email: tEmail, password: tPassword),
        ).called(1);
      },
    );
  });

  group('signInWithGoogle', () {
    test(
      'should return an SignInState with success = true when operation is successful',
      () async {
        when(
          () => mockSignInWithGoogleUseCase.call(),
        ).thenAnswer((_) async => tId);

        final signInNotifier = providerContainer.read(
          signInStateNotifierProvider.notifier,
        );

        await signInNotifier.signInWithGoogle();

        final signInState = providerContainer.read(signInStateNotifierProvider);

        final expected = SignInState(success: true, isLoading: false);

        expect(signInState, equals(expected));
        verify(() => mockSignInWithGoogleUseCase.call()).called(1);
      },
    );

    test(
      'should return an SignInState with error message "A entrada foi cancelada" when use case throws GoogleSignInCancelledException',
      () async {
        when(
          () => mockSignInWithGoogleUseCase.call(),
        ).thenThrow(GoogleSignInCancelledException());

        final signInNotifier = providerContainer.read(
          signInStateNotifierProvider.notifier,
        );

        await signInNotifier.signInWithGoogle();

        final signInState = providerContainer.read(signInStateNotifierProvider);

        final expected = SignInState(errorMessage: 'A entrada foi cancelada');

        expect(signInState, equals(expected));
        verify(() => mockSignInWithGoogleUseCase.call()).called(1);
      },
    );

    test(
      'should return an SignInState with error message "Credenciais inválidas" when use case throws InvalidCredentialsException',
      () async {
        when(
          () => mockSignInWithGoogleUseCase.call(),
        ).thenThrow(InvalidCredentialsException());

        final signInNotifier = providerContainer.read(
          signInStateNotifierProvider.notifier,
        );

        await signInNotifier.signInWithGoogle();

        final signInState = providerContainer.read(signInStateNotifierProvider);

        final expected = SignInState(errorMessage: 'Credenciais inválidas');

        expect(signInState, equals(expected));
        verify(() => mockSignInWithGoogleUseCase.call()).called(1);
      },
    );
  });
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:safeway/features/auth/presentation/state/sign_up_state.dart';
import 'package:safeway/features/auth/presentation/widgets/custom_form_text_field.dart';

import 'mock_sign_up_state_notifier.dart';

void main() {
  late TestSignUpNotifier testNotifier;
  late GoRouter router;

  Widget createWidgetUnderTest() {
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SignUpScreen()),
        GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Text('Home'))),
        GoRoute(path: '/signIn', builder: (context, state) => const Scaffold(body: Text('SignIn'))),
        GoRoute(path: '/resetPassword', builder: (context, state) => const Scaffold(body: Text('Reset'))),
      ],
    );

    return ProviderScope(
      overrides: [
        signUpStateNotifierProvider.overrideWith(() => testNotifier),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  setUp(() {
    testNotifier = TestSignUpNotifier();
  });

  testWidgets('renders all fields and buttons', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Confirmar Senha'), findsOneWidget);
    expect(find.text('Cadastrar'), findsOneWidget);
    expect(find.text('Entrar com Google'), findsOneWidget);
    expect(find.byType(CustomFormTextField), findsNWidgets(3));
  });

  testWidgets('shows error when email is empty', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(CustomFormTextField).at(1), '123456');
    await tester.enterText(find.byType(CustomFormTextField).last, '123456');
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text('Campo obrigatório'), findsOneWidget);
  });

  testWidgets('shows error when email is invalid', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(CustomFormTextField).first, 'invalidemail');
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text('E-mail inválido'), findsOneWidget);
  });

  testWidgets('shows error when password is empty', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(CustomFormTextField).first, 'test@example.com');
    await tester.enterText(find.byType(CustomFormTextField).last, '123456');
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text('Campo obrigatório'), findsOneWidget);
  });

  testWidgets('shows error when password is too short', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(CustomFormTextField).first, 'test@example.com');
    await tester.enterText(find.byType(CustomFormTextField).at(1), '123');
    await tester.enterText(find.byType(CustomFormTextField).last, '123');
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text('Senha muito curta'), findsOneWidget);
  });

  testWidgets('shows error when passwords dont match', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(CustomFormTextField).first, 'test@example.com');
    await tester.enterText(find.byType(CustomFormTextField).at(1), '1234567');
    await tester.enterText(find.byType(CustomFormTextField).last, '123456');
    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text('As senhas não coincidem'), findsOneWidget);
  });

  testWidgets('calls signUp when form is valid', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(CustomFormTextField).first, 'test@example.com');
    await tester.enterText(find.byType(CustomFormTextField).at(1), '123456');
    await tester.enterText(find.byType(CustomFormTextField).last, '123456');

    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(testNotifier.lastEmail, 'test@example.com');
    expect(testNotifier.lastPassword, '123456');
  });

  testWidgets('calls signUpWithGoogle on Google button tap', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Entrar com Google'));
    await tester.pump();

    expect(testNotifier.googleSignUpCalled, isTrue);
  });

  testWidgets('submit button shows loading when isLoading is true', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    testNotifier.setState(SignUpState(isLoading: true));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled, false);
  });

  testWidgets('navigates to home on success', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    testNotifier.setState(SignUpState(success: true));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('navigates to signIn screen', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Já tenho uma conta'));
    await tester.pumpAndSettle();

    expect(find.text('SignIn'), findsOneWidget);
  });

  testWidgets('shows SnackBar when errorMessage is set', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    testNotifier.setState(SignUpState(errorMessage: 'Credenciais inválidas'));
    await tester.pump();

    expect(find.text('Credenciais inválidas'), findsOneWidget);
  });
}

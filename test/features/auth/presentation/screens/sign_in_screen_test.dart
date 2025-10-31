import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:safeway/features/auth/presentation/state/sign_in_state.dart';
import 'package:safeway/features/auth/presentation/widgets/custom_form_text_field.dart';

import 'mock_sign_in_state_notifier.dart';

void main() {
  late TestSignInNotifier testNotifier;
  late GoRouter router;

  Widget createWidgetUnderTest() {
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SignInScreen()),
        GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Text('Home'))),
        GoRoute(path: '/signUp', builder: (context, state) => const Scaffold(body: Text('SignUp'))),
        GoRoute(path: '/resetPassword', builder: (context, state) => const Scaffold(body: Text('Reset'))),
      ],
    );

    return ProviderScope(
      overrides: [
        signInStateNotifierProvider.overrideWith(() => testNotifier),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  setUp(() {
    testNotifier = TestSignInNotifier();
  });

  testWidgets('renders all fields and buttons', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Entrar com Google'), findsOneWidget);
    expect(find.byType(CustomFormTextField), findsNWidgets(2));
  });

  testWidgets('shows error when email is empty', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(CustomFormTextField).last, '123456');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Campo obrigatório'), findsOneWidget);
  });

  testWidgets('shows error when email is invalid', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(CustomFormTextField).first, 'invalidemail');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('E-mail inválido'), findsOneWidget);
  });

  testWidgets('shows error when password is empty', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(CustomFormTextField).first, 'test@example.com');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Campo obrigatório'), findsOneWidget);
  });

  testWidgets('shows error when password is too short', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(CustomFormTextField).first, 'test@example.com');
    await tester.enterText(find.byType(CustomFormTextField).last, '123');
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Senha muito curta'), findsOneWidget);
  });

  testWidgets('calls signIn when form is valid', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.enterText(find.byType(CustomFormTextField).first, 'test@example.com');
    await tester.enterText(find.byType(CustomFormTextField).last, '123456');

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(testNotifier.lastEmail, 'test@example.com');
    expect(testNotifier.lastPassword, '123456');
  });

  testWidgets('calls signInWithGoogle on Google button tap', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Entrar com Google'));
    await tester.pump();

    expect(testNotifier.googleSignInCalled, isTrue);
  });

  testWidgets('submit button shows loading when isLoading is true', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    testNotifier.setState(SignInState(isLoading: true));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled, false);
  });

  testWidgets('navigates to home on success', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    testNotifier.setState(SignInState(success: true));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('navigates to signUp screen', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Não possuo uma conta'));
    await tester.pumpAndSettle();

    expect(find.text('SignUp'), findsOneWidget);
  });

  testWidgets('navigates to resetPassword screen', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.tap(find.text('Esqueci minha senha'));
    await tester.pumpAndSettle();

    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('shows SnackBar when errorMessage is set', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    testNotifier.setState(SignInState(errorMessage: 'Credenciais inválidas'));
    await tester.pump();

    expect(find.text('Credenciais inválidas'), findsOneWidget);
  });
}

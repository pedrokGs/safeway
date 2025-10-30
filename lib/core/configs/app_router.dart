import 'package:go_router/go_router.dart';
import 'package:safeway/common/screens/loading_screen.dart';
import 'package:safeway/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:safeway/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:safeway/features/auth/presentation/screens/sign_up_screen.dart';

import '../../common/screens/error_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
      initialLocation: 'signIn',
      errorBuilder: (context, state) => ErrorScreen(errorMessage: 'Página não encontrada'),
      routes:
    [
      GoRoute(name:'error',path: '/error', builder: (context, state) {
        final errorMessage = state.uri.queryParameters['errorMessage'] ?? 'Erro Desconhecido';
        return ErrorScreen(errorMessage: errorMessage);
      }),
      GoRoute(name:'loading', path: '/loading', builder: (context, state) => LoadingScreen()),
      GoRoute(name: 'signIn', path: '/signIn', builder: (context, state) => SignInScreen()),
      GoRoute(name: 'signUp', path: '/signUp', builder: (context, state) => SignUpScreen()),
      GoRoute(name: 'resetPassword', path: '/resetPassword', builder: (context, state) => PasswordResetScreen())
    ]
  );
}
import 'package:go_router/go_router.dart';
import 'package:safeway/common/screens/loading_screen.dart';
import 'package:safeway/core/configs/route_names.dart';
import 'package:safeway/core/configs/route_paths.dart';
import 'package:safeway/features/alerts/presentation/screens/alert_map_screen.dart';
import 'package:safeway/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:safeway/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:safeway/features/auth/presentation/screens/sign_up_screen.dart';

import '../../common/screens/error_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
      initialLocation: RoutePaths.signIn,
      errorBuilder: (context, state) => ErrorScreen(errorMessage: 'Página não encontrada'),
      routes:
      [
        GoRoute(name: RouteNames.loading, path: RoutePaths.loading, builder: (context, state) => LoadingScreen()),
        GoRoute(name: RouteNames.signIn, path: RoutePaths.signIn, builder: (context, state) => SignInScreen()),
        GoRoute(name: RouteNames.signUp, path: RoutePaths.signUp, builder: (context, state) => SignUpScreen()),
        GoRoute(name: RouteNames.resetPassword, path: RoutePaths.resetPassword, builder: (context, state) => PasswordResetScreen()),
        GoRoute(name: RouteNames.home, path: RoutePaths.home, builder: (context, state) => AlertMapScreen())
      ]
  );
}

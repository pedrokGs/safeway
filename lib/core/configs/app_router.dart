import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeway/common/screens/loading_screen.dart';
import 'package:safeway/core/configs/route_names.dart';
import 'package:safeway/core/configs/route_paths.dart';
import 'package:safeway/features/alerts/presentation/screens/alert_form_screen.dart';
import 'package:safeway/features/alerts/presentation/screens/alert_history_screen.dart';
import 'package:safeway/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:safeway/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:safeway/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:safeway/features/settings/views/screens/edit_profile_screen.dart';
import 'package:safeway/features/settings/views/screens/help_screen.dart';
import 'package:safeway/features/settings/views/screens/risk_visualization_screen.dart';
import 'package:safeway/features/settings/views/screens/settings_screen.dart';

import '../../common/screens/error_screen.dart';
import '../../features/navigation/views/screens/alert_map_screen.dart';
import '../../features/navigation/views/screens/navigation_history_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RoutePaths.signIn,
    errorBuilder: (context, state) =>
        ErrorScreen(errorMessage: 'Página não encontrada'),
    routes: [
      GoRoute(
        name: RouteNames.loading,
        path: RoutePaths.loading,
        builder: (context, state) => LoadingScreen(),
      ),
      GoRoute(
        name: RouteNames.signIn,
        path: RoutePaths.signIn,
        builder: (context, state) => SignInScreen(),
      ),
      GoRoute(
        name: RouteNames.signUp,
        path: RoutePaths.signUp,
        builder: (context, state) => SignUpScreen(),
      ),
      GoRoute(
        name: RouteNames.resetPassword,
        path: RoutePaths.resetPassword,
        builder: (context, state) => PasswordResetScreen(),
      ),
      GoRoute(
        name: RouteNames.home,
        path: RoutePaths.home,
        builder: (context, state) => AlertMapScreen(),
      ),
      GoRoute(
        name: RouteNames.alertForm,
        path: RoutePaths.alertForm,
        builder: (context, state) {
          LatLng latLng = state.extra as LatLng;
          return AlertFormScreen(latLng: latLng);
        },
      ),
      GoRoute(
        name: RouteNames.alertHistory,
        path: RoutePaths.alertHistory,
        builder: (context, state) => AlertHistoryScreen(),
      ),
      GoRoute(
        name: RouteNames.navigationHistory,
        path: RoutePaths.navigationHistory,
        builder: (context, state) => NavigationHistoryScreen(),
      ),
      GoRoute(
        name: RouteNames.settingsScreen,
        path: RoutePaths.settingsScreen,
        builder: (context, state) => SettingsScreen(),
      ),
      GoRoute(
        name: RouteNames.riskVisualization,
        path: RoutePaths.riskVisualization,
        builder: (context, state) => RiskVisualizationScreen(),
      ),
      GoRoute(
        name: RouteNames.helpScreen,
        path: RoutePaths.helpScreen,
        builder: (context, state) => HelpScreen(),
      ),
      GoRoute(
        name: RouteNames.editProfileScreen,
        path: RoutePaths.editProfileScreen,
        builder: (context, state) => EditProfileScreen(),
      ),
    ],
  );
}

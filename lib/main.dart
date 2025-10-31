import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safeway/core/configs/app_router.dart';
import 'package:safeway/core/configs/firebase_options_dev.dart';

import 'core/di/theme_providers.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: const String.fromEnvironment('ENV_FILE', defaultValue: '.env'));
  await Firebase.initializeApp(
    name: 'Safeway',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
  await GoogleSignIn.instance.initialize(serverClientId: serverClientId);

  runApp(
    ProviderScope(child: SafewayApp()),
  );
}

class SafewayApp extends ConsumerWidget {
  const SafewayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      theme: AppTheme.getTheme(false),
      darkTheme: AppTheme.getTheme(true),
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}

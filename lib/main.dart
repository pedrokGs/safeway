import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/core/configs/app_router.dart';
import 'package:safeway/core/configs/firebase_options_dev.dart';
import 'package:safeway/core/di/theme_providers.dart';
import 'package:safeway/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'Safeway',
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
      routerConfig: appRouter,
    );
  }
}
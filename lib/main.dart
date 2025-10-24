import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/core/configs/app_router.dart';
import 'package:safeway/core/configs/firebase_options_dev.dart';

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

class SafewayApp extends StatelessWidget {
  const SafewayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(

      // TODO: Implementar AppThemes no lugar de ThemeData e ThemeData.dark
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      routerConfig: AppRouter.router,
    );
  }
}

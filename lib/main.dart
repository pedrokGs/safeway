import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: const String.fromEnvironment('ENV_FILE', defaultValue: '.env'));
  await Firebase.initializeApp(
    name: 'Safeway',
    options: DefaultFirebaseOptions.currentPlatform,
  );


  final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
  await GoogleSignIn.instance.initialize(serverClientId);

  await Hive.initFlutter();

  Hive.registerAdapter(RouteHistoryModel());
  Hive.registerAdapter(LatLngAdapter());

  await Hive.openBox<RouteHistoryModel>('route_history');

  runApp(
    ProviderScope(child: SafewayApp()),
  );
}

class SafewayApp extends ConsumerWidget {
  const SafewayApp({super.key})

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(false),
      darkTheme: AppTheme.getTheme(true),
      themeMode: themeMode,
      routerConfig: AppRouter.router,
    );
  }
}

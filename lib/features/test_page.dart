import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/core/di/theme_providers.dart';

class TestPage extends ConsumerWidget {
  const TestPage({super.key});

@override
  Widget build(BuildContext context, WidgetRef ref) {
  final themeMode = ref.watch(themeNotifierProvider);
  final notifier = ref.read(themeNotifierProvider.notifier);

  return Scaffold(
    appBar: AppBar(
      title: const Text('Teste'),
      actions: [
        IconButton(
          icon: Icon(themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
          onPressed: () => notifier.toggle(),
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('Bruh'),
          ),
          const SizedBox(height: 8),
          Text('Modo atual: ${themeMode.toString().split('.').last}'),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Escuro'),
              Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (_) => notifier.toggle(),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => notifier.setMode(ThemeMode.system),
                child: const Text('Sistema'),
              ),
            ],
          ),
        ],
      ),
    ),
    bottomNavigationBar: BottomNavigationBar(items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.train_sharp),
        label: 'Train',
        tooltip: 'I always come back',
      ),
      BottomNavigationBarItem(
        label: 'Lol Lmao',
        tooltip: 'XD ez bro so ez',
        icon: Icon(Icons.face_2_outlined),
      ),
    ]),
  );
}
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safeway/common/widgets/custom_drawer.dart';
import 'package:safeway/core/configs/route_names.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/core/di/theme_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final authRepository = ref.watch(authRepositoryProvider);
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);

    bool isDark = themeNotifier.isDark;

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ------------------------
            /// PERFIL
            /// ------------------------
            Text('Perfil', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        'https://www.gravatar.com/avatar/${authRepository.currentUser!.email}?s=200&d=identicon&r=PG',
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Usuário",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          context.goNamed(RouteNames.editProfileScreen),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Editar'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            /// ------------------------
            /// CONFIGURAÇÕES
            /// ------------------------
            Text('Configurações',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.shield_outlined,
              title: "Visualização de Risco",
              onTap: () => context.goNamed(RouteNames.riskVisualization),
            ),

            const SizedBox(height: 10),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SwitchListTile(
                title: const Text("Tema"),
                subtitle: Text(isDark ? "Modo Escuro" : "Modo Claro"),
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                value: isDark,
                onChanged: (value) => themeNotifier.toggle(),
              ),
            ),

            const SizedBox(height: 28),

            /// ------------------------
            /// AJUDA
            /// ------------------------
            Text('Suporte', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: Icons.help_outline,
              title: "Central de Ajuda",
              onTap: () => context.goNamed(RouteNames.helpScreen),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safeway/core/configs/route_names.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_out_use_case.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SignOutUseCase signOutUseCase = ref.watch(signOutUseCaseProvider);

    final theme = Theme.of(context);

    final List<_DrawerItem> items = [
      _DrawerItem(
        label: 'Início',
        icon: Icons.home_rounded,
        route: RouteNames.home,
      ),
      _DrawerItem(
        label: 'Alertas',
        icon: Icons.crisis_alert_sharp,
        route: RouteNames.alertHistory,
      ),
      _DrawerItem(
        label: 'Histórico',
        icon: Icons.history,
        route: RouteNames.navigationHistory,
      ),
      _DrawerItem(
        label: 'Configurações',
        icon: Icons.settings,
        route: RouteNames.settingsScreen,
      ),
    ];

    return Drawer(
      elevation: 10,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ---------- CABEÇALHO ----------
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primaryContainer,
                    theme.colorScheme.primary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'Safeway',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isActive =
                      GoRouter.of(context).state.path == item.route;

                  return _DrawerTile(
                    item: item,
                    isActive: isActive,
                    onTap: () {
                      Navigator.pop(context); // fecha o drawer
                      context.goNamed(item.route); // navega
                    },
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // ---------- BOTÃO SAIR ----------
            ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: theme.colorScheme.error.withOpacity(0.9),
              ),
              title: Text(
                'Sair',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await signOutUseCase.call();
                if (context.mounted) {
                  GoRouter.of(context).goNamed('signIn');
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  final String label;
  final IconData icon;
  final String route;

  const _DrawerItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class _DrawerTile extends StatelessWidget {
  final _DrawerItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          item.label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

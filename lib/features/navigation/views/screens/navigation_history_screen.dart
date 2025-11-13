import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:safeway/common/widgets/custom_drawer.dart';
import 'package:safeway/core/di/theme_providers.dart';

import '../../models/route_history_model.dart';

class NavigationHistoryScreen extends ConsumerStatefulWidget {
  const NavigationHistoryScreen({super.key});

  @override
  NavigationHistoryScreenState createState() => NavigationHistoryScreenState();
}

class NavigationHistoryScreenState extends ConsumerState<NavigationHistoryScreen> {
  late final Box<RouteHistoryModel> _routeBox;

  @override
  void initState() {
    super.initState();
    _routeBox = Hive.box<RouteHistoryModel>('route_history');
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);
    final themeMode = ref.watch(themeNotifierProvider);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await themeNotifier.toggle();
            },
            icon: themeMode == ThemeMode.dark
                ? const Icon(Icons.dark_mode)
                : const Icon(Icons.light_mode),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: _routeBox.listenable(),
        builder: (context, Box<RouteHistoryModel> box, _) {
          final routes = box.values.toList().reversed.toList();

          if (routes.isEmpty) {
            return const Center(
              child: Text('Nenhum histórico de rota encontrado.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            itemCount: routes.length,
            itemBuilder: (context, index) {
              final route = routes[index];
              final etaMinutes = (route.etaSeconds / 60).toStringAsFixed(0);
              final origem = route.origem;
              final destino = route.destino;

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Indicador de modo
                    Container(
                      width: 8,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _modeColor(route.transportMode, colorScheme),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// --- MODO DE TRANSPORTE ---
                          Text(
                            _modeLabel(route.transportMode),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),

                          const SizedBox(height: 4),

                          /// --- TEMPO ESTIMADO ---
                          Text(
                            'Tempo estimado: $etaMinutes min',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                              'Origem: ${origem}'
                          ),

                          Text('Destino: ${destino}'),

                          const SizedBox(height: 8,),

                          /// --- DETALHES ---
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Spacer(),
                              Text(
                                DateFormat.MMMd().format(route.createdAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat.Hm().format(route.createdAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _modeColor(String mode, ColorScheme scheme) {
    switch (mode) {
      case 'car':
        return Colors.blueAccent;
      case 'bike':
        return Colors.green;
      case 'walking':
        return Colors.orange;
      default:
        return scheme.primary;
    }
  }

  String _modeLabel(String mode) {
    switch (mode) {
      case 'car':
        return 'Rota de carro';
      case 'bike':
        return 'Rota de bicicleta';
      case 'walking':
        return 'Rota a pé';
      default:
        return 'Rota desconhecida';
    }
  }
}

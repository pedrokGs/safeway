import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:safeway/core/di/alert_providers.dart';
import 'package:safeway/core/di/theme_providers.dart';
import 'package:safeway/common/widgets/custom_drawer.dart';
import 'package:safeway/features/navigation/views/utils/convert_risk_to_color.dart';

class AlertHistoryScreen extends ConsumerStatefulWidget {
  const AlertHistoryScreen({super.key});

  @override
  ConsumerState<AlertHistoryScreen> createState() => _AlertHistoryScreenState();
}

class _AlertHistoryScreenState extends ConsumerState<AlertHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = ref.watch(themeNotifierProvider.notifier);
    final themeMode = ref.watch(themeNotifierProvider);

    final alertNotifier = ref.watch(alertMapNotifierProvider.notifier);
    final state = ref.watch(alertMapNotifierProvider);

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(Icons.menu),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await themeNotifier.toggle();
            },
            icon: themeMode == ThemeMode.dark
                ? Icon(Icons.dark_mode)
                : Icon(Icons.light_mode),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text('Alertas', style: Theme.of(context).textTheme.titleMedium),

                Builder(
                  builder: (context) {
                    return Column(
                      children: state.alerts.map((alert) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).shadowColor.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ícone ou indicador de tipo/risco
                              Container(
                                width: 8,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: alertRiskToColor(alert.risco),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Conteúdo textual
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// --- TÍTULO ---
                                    Text(
                                      alert.titulo ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                          ),
                                    ),

                                    const SizedBox(height: 4),

                                    /// --- DESCRIÇÃO ---
                                    Text(
                                      alert.descricao,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                          ),
                                    ),

                                    const SizedBox(height: 8),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tipo: ${alert.tipo.name}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                        ),
                                        SizedBox(width: 8),

                                        Text(
                                          'Risco: ${alert.risco.name}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        Spacer(),

                                        Text(
                                          DateFormat.MMMd().format(alert.data),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.outline,
                                              ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          DateFormat.Hm().format(alert.data),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.outline,
                                              ),
                                        ),
                                      ],
                                    ),
                                    FutureBuilder(
                                      future: placemarkFromCoordinates(
                                        alert.latitude,
                                        alert.longitude,
                                      ),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        }
                                        if (!snapshot.hasData ||
                                            snapshot.hasError) {
                                          return Text(
                                            'Ocorreu um erro ao buscar endereço',
                                          );
                                        }
                                        return Text(
                                          '${snapshot.data!.first.street!}, ${snapshot.data!.first.subLocality}, ${snapshot.data!.first.subAdministrativeArea}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.outline,
                                              ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

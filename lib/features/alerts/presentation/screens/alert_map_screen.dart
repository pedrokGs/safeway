import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeway/core/di/theme_providers.dart';
import 'package:safeway/core/utils/convert_risk_to_color.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/presentation/screens/alert_form_screen.dart';
import 'package:safeway/features/alerts/presentation/state/alert_map_state.dart';
import 'package:safeway/features/alerts/presentation/widgets/alert_info_container.dart';
import 'package:safeway/features/alerts/presentation/widgets/custom_text_field.dart';

import '../../../../core/di/alert_providers.dart';

class AlertMapScreen extends ConsumerStatefulWidget {
  const AlertMapScreen({super.key});

  @override
  ConsumerState<AlertMapScreen> createState() => _AlertMapScreenState();
}

class _AlertMapScreenState extends ConsumerState<AlertMapScreen> {
  final MapController _mapController = MapController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(alertMapNotifierProvider.notifier);
    notifier.getCurrentPosition().then((_) => notifier.startTracking());
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    final state = ref.watch(alertMapNotifierProvider);
    final notifier = ref.read(alertMapNotifierProvider.notifier);

    final cityBounds = LatLngBounds(
      LatLng(-22.6400, -47.4600),
      LatLng(-22.5500, -47.3400),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading:
          IconButton(
            onPressed: () async {
              await themeNotifier.toggle();
            },
            icon: themeMode == ThemeMode.dark
                ? Icon(Icons.dark_mode)
                : Icon(Icons.light_mode),
          ),
          actions: [SizedBox(
            height: 48,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AlertFormScreen(latLng: state.currentPosition!,),));
            }, icon:Icon(Icons.crisis_alert), label: Text('Alertar Autoridades')),
          )
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialZoom: 13,
                initialCenter: cityBounds.center,
                minZoom: 1.0,
                maxZoom: 17.0,
                // cameraConstraint: CameraConstraint.contain(bounds: cityBounds),
                onTap: (_, __) => FocusScope.of(context).unfocus(),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/${ref.watch(themeNotifierProvider).name}_all/{z}/{x}/{y}{r}.png',
                  userAgentPackageName: 'com.safeway.app',
                ),
                if (state.alerts.isNotEmpty)
                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 45,
                      padding: const EdgeInsets.all(12.0),
                      computeSize: (markers) {
                        final clusterSize = 50.0 + markers.length * 5;
                        final size = clusterSize.clamp(50.0, 100.0);
                        return Size(size, size);
                      },
                      markers: state.alerts.map((alert) {
                        return Marker(
                          key: ValueKey(alert.uid),
                          width: 40,
                          height: 40,
                          point: LatLng(alert.latitude, alert.longitude),
                          child: GestureDetector(
                            onTap: () {
                              showAdaptiveDialog(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) {
                                  return GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {},
                                          child: AlertInfoContainer(
                                            alertEntity: alert,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: alertRiskToColor(
                                  alert.risco,
                                ).withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      builder: (context, markers) => Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (state.currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: state.currentPosition!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.my_location,
                          color: Colors.blueAccent,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          if (state.isLoading)
            const Positioned.fill(
              child: Center(child: CircularProgressIndicator()),
            ),
          if (state.error != null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                color: Colors.redAccent,
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              bottom: false,
              child: Container(
                color: Theme.of(context).colorScheme.surface,
                height: MediaQuery.of(context).size.height * 0.3,
                alignment: Alignment.center,
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      'Para onde você deseja ir?',
                      style: Theme.of(context).textTheme.titleSmall
                    ),
                    const SizedBox(height: 12,),
                    CustomTextField(controller: _locationController)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_searching),
        onPressed: () {
          final currentPos = state.currentPosition!;
          if (cityBounds.contains(currentPos)) {
            _mapController.move(currentPos, 15);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Você está fora da área do mapa!')),
            );
          }

        },
      ),
    );
  }
}

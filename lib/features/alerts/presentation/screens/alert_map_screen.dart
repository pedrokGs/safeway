import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/di/alert_providers.dart';

class AlertMapScreen extends ConsumerStatefulWidget {
  const AlertMapScreen({super.key});

  @override
  ConsumerState<AlertMapScreen> createState() => _AlertMapScreenState();
}

class _AlertMapScreenState extends ConsumerState<AlertMapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();

    final notifier = ref.read(alertMapNotifierProvider.notifier);
    notifier.getCurrentPosition().then((_) {
      notifier.startTracking();
    });
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertMapNotifierProvider);
    final notifier = ref.read(alertMapNotifierProvider.notifier);
    
    final cityBounds = LatLngBounds(LatLng(-22.6400, -47.4600), LatLng(-22.5500, -47.3400));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state.currentPosition != null) {
        _mapController.move(state.currentPosition!, 15);
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(-22.5876, -47.4015),
                initialZoom: 13,
                minZoom: 11.0,
                maxZoom: 17.0,
                cameraConstraint: CameraConstraint.contain(bounds: cityBounds),
                onTap: (_, __) => FocusScope.of(context).unfocus(),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.safeway.app',
                ),
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 45,
                    size: const Size(40, 40),
                    padding: EdgeInsets.all(12.0),
                    markers: state.alerts.map((alert) {
                      return Marker(
                        width: 40,
                        height: 40,
                        point: LatLng(alert.latitude, alert.longitude),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.redAccent,
                          size: 36,
                        ),
                      );
                    }).toList(),
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
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
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: notifier.createFakeAlert,
        icon: const Icon(Icons.add_alert),
        label: const Text('Criar Alerta'),
      ),
    );
  }
}

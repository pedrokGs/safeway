import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeway/core/di/theme_providers.dart';
import 'package:safeway/features/alerts/presentation/utils/convert_risk_to_color.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/presentation/screens/alert_form_screen.dart';
import 'package:safeway/features/alerts/presentation/state/alert_map_state.dart';
import 'package:safeway/features/alerts/presentation/utils/get_route_points.dart';
import 'package:safeway/features/alerts/presentation/utils/speed_time_calculator.dart';
import 'package:safeway/features/alerts/presentation/widgets/alert_info_container.dart';
import 'package:safeway/features/alerts/presentation/widgets/custom_text_field.dart';

import '../../../../core/di/alert_providers.dart';
import '../utils/nomination_autocomplete.dart';

class AlertMapScreen extends ConsumerStatefulWidget {
  const AlertMapScreen({super.key});

  @override
  ConsumerState<AlertMapScreen> createState() => _AlertMapScreenState();
}

class _AlertMapScreenState extends ConsumerState<AlertMapScreen> {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  final _locationController = TextEditingController();
  List<String> _suggestions = [];
  bool _isLoadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    final notifier = ref.read(alertMapNotifierProvider.notifier);
    notifier.getCurrentPosition().then((_) => notifier.startTracking());
  }

  Future<void> _createRoute() async {
    final currentPos = ref.read(alertMapNotifierProvider).currentPosition;
    final destinationText = _locationController.text.trim();

    if (currentPos == null || destinationText.isEmpty) return;

    try {
      final dest = await ref
          .read(alertMapNotifierProvider.notifier)
          .getCoordinatesFromAddress(destinationText);
      if (dest == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço não encontrado.')),
        );
        return;
      }

      final route = await getRoutePoints(currentPos, dest);

      setState(() {
        _routePoints = route;
      });

      ref.read(alertMapNotifierProvider.notifier).calculateEta(route);

      _mapController.fitCamera(
        CameraFit.bounds(bounds: LatLngBounds.fromPoints([...route])),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao gerar rota: $e')));
    }
  }

  Future<void> _updateSuggestions(String value) async {
    if (value.length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    setState(() => _isLoadingSuggestions = true);

    final results = await getAddressSuggestions(value);

    setState(() {
      _suggestions = results;
      _isLoadingSuggestions = false;
    });
  }
  Widget _buildModeButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required bool selected,
        required VoidCallback onTap,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primary : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            if (selected)
              BoxShadow(
                blurRadius: 6,
                color: colorScheme.primary.withOpacity(0.4),
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : colorScheme.onSurface),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : colorScheme.onSurface,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);

    final state = ref.watch(alertMapNotifierProvider);
    final notifier = ref.read(alertMapNotifierProvider.notifier);

    final cityBounds = LatLngBounds(
      LatLng(-22.572959, -47.477806),
      LatLng(-22.5500, -47.3400),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () async {
            await themeNotifier.toggle();
          },
          icon: themeMode == ThemeMode.dark
              ? Icon(Icons.dark_mode)
              : Icon(Icons.light_mode),
        ),
        actions: [
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AlertFormScreen(latLng: state.currentPosition!),
                  ),
                );
              },
              icon: Icon(Icons.crisis_alert),
              label: Text('Alertar Autoridades'),
            ),
          ),
        ],
      ),
      body: (state.currentPosition == null || state.isLoading)
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialZoom: 13,
                      initialCenter: cityBounds.center,
                      minZoom: 1.0,
                      maxZoom: 17.0,
                      // cameraConstraint: CameraConstraint.contain(bounds: cityBounds,),
                      onTap: (_, __) => FocusScope.of(context).unfocus(),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.basemaps.cartocdn.com/${ref.watch(themeNotifierProvider).name}_all/{z}/{x}/{y}{r}.png',
                        subdomains: const ['a', 'b', 'c', 'd'],
                        userAgentPackageName: 'com.github.pedrokgs.safeway.dev',
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
                                          onTap: () =>
                                              Navigator.of(context).pop(),
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
                      if (_routePoints.isNotEmpty)
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _routePoints,
                              color: Colors.blueAccent,
                              strokeWidth: 4,
                            ),
                          ],
                        ),

                      if (_routePoints.isNotEmpty)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(
                                _routePoints.last.latitude,
                                _routePoints.last.longitude,
                              ),
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 28,
                              ),
                            ),
                          ],
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
                                color: Colors.amber,
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
                DraggableScrollableSheet(
                  initialChildSize: 0.25,
                  minChildSize: 0.2,
                  maxChildSize: 0.6,
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ],
                      ),
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[400],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          Text(
                            'Para onde você deseja ir?',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 12),
                          CustomTextField(
                            controller: _locationController,
                            icon: const Icon(Icons.location_pin),
                            onChanged: _updateSuggestions,
                          ),
                          const SizedBox(height:  8,),
                          if (_routePoints.isNotEmpty && state.etaSeconds != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'Tempo estimado: ${notifier.formattedEta}',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          const SizedBox(height: 8,),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildModeButton(
                                  context,
                                  icon: Icons.directions_car,
                                  label: 'Carro',
                                  selected: state.selectedMode == TransportMode.car,
                                  onTap: () {
                                    notifier.changeMode(TransportMode.car, currentRoute: _routePoints);
                                  },
                                ),
                                _buildModeButton(
                                  context,
                                  icon: Icons.pedal_bike,
                                  label: 'Bicicleta',
                                  selected: state.selectedMode == TransportMode.bike,
                                  onTap: () {
                                    notifier.changeMode(TransportMode.bike, currentRoute: _routePoints);
                                  },
                                ),
                                _buildModeButton(
                                  context,
                                  icon: Icons.directions_walk,
                                  label: 'Caminhar',
                                  selected: state.selectedMode == TransportMode.walking,
                                  onTap: () {
                                    notifier.changeMode(TransportMode.walking, currentRoute: _routePoints);
                                  },
                                ),
                              ],),
                          if (_isLoadingSuggestions)
                            const Padding(
                              padding: EdgeInsets.only(top: 32),
                              child: LinearProgressIndicator(),
                            ),
                          if (_suggestions.isNotEmpty)
                            Container(
                              constraints: const BoxConstraints(maxHeight: 220),
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 8,
                                    color: Colors.black.withOpacity(0.1),
                                  ),
                                ],
                              ),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                shrinkWrap: true,
                                itemCount: _suggestions.length,
                                itemBuilder: (context, index) {
                                  final suggestion = _suggestions[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Material(
                                      color: Theme.of(context).colorScheme.surface,
                                      elevation: 1,
                                      borderRadius: BorderRadius.circular(12),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(12),
                                        onTap: () async {
                                          _locationController.text = suggestion;
                                          setState(() => _suggestions = []);
                                          await _createRoute();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  suggestion,
                                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                    color: Theme.of(context).colorScheme.onSurface,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.location_searching, color: Colors.amber,),
        onPressed: () {
          final currentPos = state.currentPosition!;
            _mapController.move(currentPos, 15);
        },
      ),
    );
  }
}

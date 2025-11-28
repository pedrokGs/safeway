import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeway/core/di/theme_providers.dart';
import 'package:safeway/common/widgets/custom_drawer.dart';
import 'package:safeway/features/alerts/presentation/widgets/custom_text_field.dart';
import 'package:flutter/services.dart'; // Para HapticFeedback
import 'dart:async';

import '../../../../core/di/alert_providers.dart';
import '../utils/convert_risk_to_color.dart';
import '../utils/get_route_points.dart';
import '../utils/speed_time_calculator.dart';
import '../widgets/alert_info_container.dart';

class AlertMapScreen extends ConsumerStatefulWidget {
  const AlertMapScreen({super.key});

  @override
  ConsumerState<AlertMapScreen> createState() => _AlertMapScreenState();
}

class _AlertMapScreenState extends ConsumerState<AlertMapScreen>
    with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  List<LatLng> _routePoints = [];
  bool calculatingRoute = false;
  final _locationController = TextEditingController();
  late DraggableScrollableController _sheetController;

  @override
  void initState() {
    super.initState();
    _sheetController = DraggableScrollableController();
    final notifier = ref.read(alertMapNotifierProvider.notifier);
    notifier.getCurrentPosition().then((_) => notifier.startTracking());
  }

  Future<void> _createRoute() async {
    setState(() {
      calculatingRoute = true;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Fecha o sheet para ver melhor o mapa
    _sheetController.animateTo(
      0.2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );

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

      // Feedback tátil e visual durante cálculo
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 300));

      final route = await getRoutePoints(currentPos, dest);

      // Pequena animação para desenhar a rota
      for (int i = 1; i <= route.length; i++) {
        await Future.delayed(const Duration(milliseconds: 10));
        setState(() {
          _routePoints = route.sublist(0, i);
        });
      }

      ref.read(alertMapNotifierProvider.notifier).calculateEta(route);

      _mapController.fitCamera(
        CameraFit.bounds(bounds: LatLngBounds.fromPoints([...route])),
      );

      final etaSeconds = ref.read(alertMapNotifierProvider).etaSeconds ?? 0;
      final mode = ref.read(alertMapNotifierProvider).selectedMode.name;
      final origem = await placemarkFromCoordinates(
        route.first.latitude,
        route.first.longitude,
      );
      final destino = await placemarkFromCoordinates(
        route.last.latitude,
        route.last.longitude,
      );

      await ref
          .read(alertMapNotifierProvider.notifier)
          .salvarRota(
        route,
        etaSeconds,
        mode,
        origem.first.street!,
        destino.first.street!,
      );

      // Após calcular, abre o sheet para mostrar info da rota
      _sheetController.animateTo(
        0.3,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );

      // Suave vibração de sucesso
      HapticFeedback.heavyImpact();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao gerar rota: $e')));
    } finally {
      setState(() {
        calculatingRoute = false;
      });
    }
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
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: MediaQuery.of(context).size.width * 0.25,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
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
    final state = ref.watch(alertMapNotifierProvider);

    final notifier = ref.read(alertMapNotifierProvider.notifier);

    final searchState = ref.watch(locationSearchProvider);
    final searchNotifier = ref.read(locationSearchProvider.notifier);

    final filter = ref.watch(alertFilterProvider);

    var filteredAlerts = state.alerts;

    if (filter.categorias.isNotEmpty) {
      filteredAlerts = filteredAlerts
          .where((a) => filter.categorias.contains(a.tipo))
          .toList();
    }

    if (filter.riscos.isNotEmpty) {
      filteredAlerts = filteredAlerts
          .where((a) => filter.riscos.contains(a.risco))
          .toList();
    }

    final cityBounds = LatLngBounds(
      LatLng(-22.572959, -47.477806),
      LatLng(-22.5500, -47.3400),
    );

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ),
      ),
      body: (state.currentPosition == null || state.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialZoom: 10,
                initialCenter: cityBounds.center,
                minZoom: 1.0,
                maxZoom: 17.0,
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
                      maxClusterRadius: 120,
                      padding: const EdgeInsets.all(12.0),
                      computeSize: (amount) {
                        final baseSize = 75;
                        final extraPerMarker = 25;
                        final size = (baseSize + extraPerMarker * (amount.length - 1)).clamp(50, 150).toDouble();
                        return Size(size, size);
                      },

                      size: const Size(50, 50),
                      markers: filteredAlerts.map((alert) {
                        return Marker(
                          key: ValueKey(alert.uid),
                          width: 40,
                          height: 40,
                          point: LatLng(alert.latitude, alert.longitude),
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
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
                                ).withOpacity(0.6),
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
                      builder: (context, markers) {
                        Color clusterColor;
                        String dangerLevel;
                        if (markers.length <= 3) {
                          clusterColor = Colors.green;
                          dangerLevel = 'Seguro';
                        } else if (markers.length <= 8) {
                          clusterColor = Colors.yellow;
                          dangerLevel = 'Atenção';
                        } else {
                          clusterColor = Colors.red;
                          dangerLevel = 'Perigoso';
                        }

                        final avgLat = markers
                            .map((m) => m.point.latitude)
                            .reduce((a, b) => a + b) /
                            markers.length;
                        final avgLng = markers
                            .map((m) => m.point.longitude)
                            .reduce((a, b) => a + b) /
                            markers.length;

                        return FutureBuilder<List<Placemark>>(
                          future: placemarkFromCoordinates(
                            avgLat,
                            avgLng,
                          ),
                          builder: (context, snapshot) {
                            String neighborhood = '';
                            if (snapshot.hasData &&
                                snapshot.data!.isNotEmpty) {
                              neighborhood =
                                  snapshot.data!.first.subLocality ?? '';
                            }

                            final size = ((50 + markers.length * 15)
                                .clamp(50, 120)
                                .toDouble());

                            return Container(
                              decoration: BoxDecoration(
                                color: clusterColor.withOpacity(0.7),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      markers.length.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (neighborhood.isNotEmpty)
                                      Text(
                                        neighborhood,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: size * 0.175,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    Text(
                                      dangerLevel,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: size * 0.175,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
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
                          color: Colors.lightGreen,
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
            controller: _sheetController,
            initialChildSize: 0.3,
            minChildSize: 0.2,
            maxChildSize: 0.65,
            builder: (context, scrollController) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
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
                      onChanged: (value) {
                        searchNotifier.updateSuggestions(value);
                        // Ao digitar, abre o sheet totalmente
                        _sheetController.animateTo(
                          0.65,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    if (_routePoints.isNotEmpty &&
                        state.etaSeconds != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Tempo estimado: ${notifier.formattedEta}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildModeButton(
                          context,
                          icon: Icons.directions_car,
                          label: 'Carro',
                          selected:
                          state.selectedMode == TransportMode.car,
                          onTap: () {
                            notifier.changeMode(
                              TransportMode.car,
                              currentRoute: _routePoints,
                            );
                          },
                        ),
                        _buildModeButton(
                          context,
                          icon: Icons.pedal_bike,
                          label: 'Bicicleta',
                          selected:
                          state.selectedMode == TransportMode.bike,
                          onTap: () {
                            notifier.changeMode(
                              TransportMode.bike,
                              currentRoute: _routePoints,
                            );
                          },
                        ),
                        _buildModeButton(
                          context,
                          icon: Icons.directions_walk,
                          label: 'Caminhar',
                          selected:
                          state.selectedMode == TransportMode.walking,
                          onTap: () {
                            notifier.changeMode(
                              TransportMode.walking,
                              currentRoute: _routePoints,
                            );
                          },
                        ),
                      ],
                    ),
                    if (searchState.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: LinearProgressIndicator(),
                      ),
                    if (searchState.suggestions.isNotEmpty)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 220),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
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
                          itemCount: searchState.suggestions.length,
                          itemBuilder: (context, index) {
                            final suggestion =
                            searchState.suggestions[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Material(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface,
                                elevation: 1,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    _locationController.text = suggestion;
                                    searchNotifier.clear();
                                    await _createRoute();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_outlined,
                                          size: 20,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            suggestion,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                            maxLines: 2,
                                            overflow:
                                            TextOverflow.ellipsis,
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
          if (calculatingRoute)
            const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.location_searching, color: Colors.amber),
        onPressed: () {
          final currentPos = state.currentPosition!;
          _mapController.move(currentPos, 20);
        },
      ),
    );
  }
}

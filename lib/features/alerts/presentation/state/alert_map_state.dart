import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safeway/features/alerts/domain/usecases/create_alert_use_case.dart';
import 'package:safeway/features/alerts/domain/usecases/watch_all_alerts_use_case.dart';

import '../utils/speed_time_calculator.dart';

class MapPageState extends Equatable {
  final List<AlertEntity> alerts;
  final bool isLoading;
  final String? error;
  final LatLng? currentPosition;
  final double? etaSeconds;
  final TransportMode selectedMode;

  const MapPageState({
    this.alerts = const [],
    this.isLoading = false,
    this.error,
    this.currentPosition,
    this.etaSeconds,
    this.selectedMode = TransportMode.car,
  });

  MapPageState copyWith({
    List<AlertEntity>? alerts,
    bool? isLoading,
    String? error,
    LatLng? currentPosition,
    double? etaSeconds,
    TransportMode? selectedMode,
  }) {
    return MapPageState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPosition: currentPosition ?? this.currentPosition,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      selectedMode: selectedMode ?? this.selectedMode,
    );
  }

  @override
  List<Object?> get props =>
      [alerts, isLoading, error, currentPosition, etaSeconds, selectedMode];
}


class AlertMapNotifier extends StateNotifier<MapPageState> {
  final WatchAllAlertsUseCase _watchAllAlertsUseCase;
  final CreateAlertUseCase _createAlertUseCase;
  StreamSubscription? _subscription;
  StreamSubscription<Position>? _positionStream;

  AlertMapNotifier(this._watchAllAlertsUseCase, this._createAlertUseCase)
      : super(const MapPageState()) {
    _listenToAlerts();
  }

  void _listenToAlerts() {
    state = state.copyWith(isLoading: true);
    _subscription = _watchAllAlertsUseCase().listen(
          (alerts) {
        state = state.copyWith(alerts: alerts, isLoading: false);
      },
      onError: (e) {
        state = state.copyWith(error: e.toString(), isLoading: false);
      },
    );
  }

  void calculateEta(List<LatLng> routePoints, {double trafficMultiplier = 1.0}) {
    if (routePoints.isEmpty) return;

    final eta = estimateEtaInSeconds(
      routePoints: routePoints,
      transportMode: state.selectedMode,
      trafficMultiplier: trafficMultiplier,
    );

    state = state.copyWith(etaSeconds: eta);
  }

  void changeMode(TransportMode newMode, {List<LatLng>? currentRoute}) {
    state = state.copyWith(selectedMode: newMode);

    if (currentRoute != null && currentRoute.isNotEmpty) {
      calculateEta(currentRoute);
    }
  }

  String? get formattedEta {
    final eta = state.etaSeconds;
    if (eta == null) return null;
    return formatDurationFromSeconds(eta);
  }

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
    } catch (e) {
      print('Erro ao buscar coordenadas: $e');
    }
    return null;
  }

  Future<void> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(error: "Serviço de localização desativado");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(error: "Permissão de localização negada");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(error: "Permissão de localização permanentemente negada");
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      state = state.copyWith(
        currentPosition: LatLng(position.latitude, position.longitude),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void startTracking() {
    _positionStream?.cancel();
    _positionStream = Geolocator.getPositionStream().listen((position) {
      state = state.copyWith(
        currentPosition: LatLng(position.latitude, position.longitude),
      );
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
}
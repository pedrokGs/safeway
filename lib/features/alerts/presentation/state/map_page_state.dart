import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/domain/enums/alert_type.dart';
import 'package:safeway/features/alerts/domain/usecases/create_alert_use_case.dart';
import 'package:safeway/features/alerts/domain/usecases/watch_all_alerts_use_case.dart';
import 'package:safeway/features/alerts/presentation/state/map_page_state.dart';

class MapPageState extends Equatable {
  final List<AlertEntity> alerts;
  final bool isLoading;
  final String? error;
  final LatLng? currentPosition;

  const MapPageState({
    this.alerts = const [],
    this.isLoading = false,
    this.error,
    this.currentPosition,
  });

  MapPageState copyWith({
    List<AlertEntity>? alerts,
    bool? isLoading,
    String? error,
    LatLng? currentPosition,
  }) {
    return MapPageState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }

  @override
  List<Object?> get props => [alerts, isLoading, error, currentPosition];
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

  Future<void> createFakeAlert() async {
    try {
      final alert = AlertEntity(
        uid: '',
        titulo: 'Alerta de Teste',
        descricao: 'Criado manualmente pelo botão',
        tipo: AlertType.incendio,
        risco: AlertRisk.medio,
        data: DateTime.now(),
        latitude: -23.5505,
        longitude: -46.6333,
        userId: 'demo',
      );
      await _createAlertUseCase(alert);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
}
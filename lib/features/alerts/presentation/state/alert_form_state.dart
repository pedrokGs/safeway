import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/usecases/create_alert_use_case.dart';

class AlertFormState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  const AlertFormState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  AlertFormState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return AlertFormState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, error];
}

class AlertFormNotifier extends StateNotifier<AlertFormState> {
  final CreateAlertUseCase _createAlertUseCase;

  AlertFormNotifier(this._createAlertUseCase)
      : super(const AlertFormState());

  Future<void> createAlert(AlertEntity alert) async {
    state = state.copyWith(isLoading: true, isSuccess: false, error: null);

    try {
      await _createAlertUseCase(alert);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const AlertFormState();
  }
}

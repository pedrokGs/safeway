import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/enums/alert_risk.dart';
import '../../domain/enums/alert_type.dart';
class AlertFilterState {
  final List<AlertType> categorias;
  final List<AlertRisk> riscos;

  AlertFilterState({
    this.categorias = const [],
    this.riscos = const [],
  });

  AlertFilterState copyWith({
    List<AlertType>? categorias,
    List<AlertRisk>? riscos,
  }) {
    return AlertFilterState(
      categorias: categorias ?? this.categorias,
      riscos: riscos ?? this.riscos,
    );
  }
}

class AlertFilterNotifier extends StateNotifier<AlertFilterState> {
  AlertFilterNotifier() : super(AlertFilterState());

  // Toggle categoria
  void toggleCategoria(AlertType categoria) {
    final current = List<AlertType>.from(state.categorias);

    if (current.contains(categoria)) {
      current.remove(categoria);
    } else {
      current.add(categoria);
    }

    state = state.copyWith(categorias: current);
  }

  // Toggle risco
  void toggleRisco(AlertRisk risco) {
    final current = List<AlertRisk>.from(state.riscos);

    if (current.contains(risco)) {
      current.remove(risco);
    } else {
      current.add(risco);
    }

    state = state.copyWith(riscos: current);
  }

  // Reset
  void clear() {
    state = AlertFilterState();
  }
}


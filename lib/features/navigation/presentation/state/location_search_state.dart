import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/features/navigation/presentation/utils/nomination_autocomplete.dart';

class LocationSearchState {
  final List<String> suggestions;
  final bool isLoading;

  const LocationSearchState({
    this.suggestions = const [],
    this.isLoading = false,
  });
}

class LocationSearchNotifier extends StateNotifier<LocationSearchState> {
  LocationSearchNotifier() : super(const LocationSearchState());

  Timer? _debounce;
  String _lastQuery = '';

  Future<void> updateSuggestions(String value) async {
    if (value == _lastQuery) return;
    _lastQuery = value;

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (value.length < 3) {
        state = const LocationSearchState();
        return;
      }

      state = const LocationSearchState(isLoading: true);

      try {
        final results = await getAddressSuggestions(value);
        state = LocationSearchState(
          suggestions: results,
          isLoading: false,
        );
      } catch (e) {
        state = const LocationSearchState(isLoading: false);
      }
    });
  }

  void clear() {
    _debounce?.cancel();
    _lastQuery = '';
    state = const LocationSearchState();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

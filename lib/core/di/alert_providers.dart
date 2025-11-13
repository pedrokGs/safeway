import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/alerts/data/datasources/alert_remote_datasource.dart';
import 'package:safeway/features/alerts/data/datasources/alert_remote_datasource_firebase.dart';
import 'package:safeway/features/alerts/data/repositories/alert_repository_impl.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';
import 'package:safeway/features/alerts/domain/usecases/create_alert_use_case.dart';
import 'package:safeway/features/alerts/domain/usecases/delete_alert_use_case.dart';
import 'package:safeway/features/alerts/domain/usecases/get_all_alerts_by_risk_use_case.dart';
import 'package:safeway/features/alerts/domain/usecases/get_all_alerts_by_type_use_case.dart';
import 'package:safeway/features/alerts/domain/usecases/get_all_alerts_use_case.dart';
import 'package:safeway/features/alerts/domain/usecases/update_alert_use_case.dart';
import 'package:safeway/features/alerts/domain/usecases/watch_all_alerts_use_case.dart';

import '../../features/alerts/presentation/state/alert_form_state.dart';
import '../../features/navigation/presentation/state/alert_map_state.dart';
import '../../features/navigation/presentation/state/location_search_state.dart';

// Data
final cloudFirestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance,);
final alertRemoteDataSourceProvider = Provider<AlertRemoteDataSource>((ref) => AlertRemoteDataSourceFirebase(firestore: ref.watch(cloudFirestoreProvider), authRepository: ref.watch(authRepositoryProvider)));
final alertRepositoryProvider = Provider<AlertRepository>((ref) => AlertRepositoryImpl(datasource: ref.watch(alertRemoteDataSourceProvider)));

// Use Cases
final createAlertUseCaseProvider = Provider<CreateAlertUseCase>((ref) => CreateAlertUseCase(repository: ref.watch(alertRepositoryProvider)));
final deleteAlertUseCaseProvider = Provider<DeleteAlertUseCase>((ref) => DeleteAlertUseCase(repository: ref.watch(alertRepositoryProvider)));
final getAllAlertsByRiskUseCaseProvider = Provider<GetAllAlertsByRiskUseCase>((ref) => GetAllAlertsByRiskUseCase(repository: ref.watch(alertRepositoryProvider)));
final getAllAlertsByTypeUseCaseProvider = Provider<GetAllAlertsByTypeUseCase>((ref) => GetAllAlertsByTypeUseCase(repository: ref.watch(alertRepositoryProvider)));
final getAllAlertsUseCaseProvider = Provider<GetAllAlertsUseCase>((ref) => GetAllAlertsUseCase(repository: ref.watch(alertRepositoryProvider)));
final updateAlertUseCaseProvider = Provider<UpdateAlertUseCase>((ref) => UpdateAlertUseCase(repository: ref.watch(alertRepositoryProvider)));
final watchAllAlertsUseCaseProvider = Provider<WatchAllAlertsUseCase>((ref) => WatchAllAlertsUseCase(repository: ref.watch(alertRepositoryProvider)));

// Presentation
final alertMapNotifierProvider =
StateNotifierProvider<AlertMapNotifier, MapPageState>((ref) {
  final watchAll = ref.watch(watchAllAlertsUseCaseProvider);
  final create = ref.watch(createAlertUseCaseProvider);
  return AlertMapNotifier(watchAll, create);
});

final alertFormNotifierProvider =
StateNotifierProvider<AlertFormNotifier, AlertFormState>(
      (ref) => AlertFormNotifier(ref.watch(createAlertUseCaseProvider)),
);

final locationSearchProvider =
StateNotifierProvider<LocationSearchNotifier, LocationSearchState>((ref) {
  return LocationSearchNotifier();
});
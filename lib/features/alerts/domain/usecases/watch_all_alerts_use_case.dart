import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class WatchAllAlertsUseCase{
  final AlertRepository repository;

  const WatchAllAlertsUseCase({required this.repository});

  Stream<List<AlertEntity>> call() {
    return repository.watchAllAlerts();
  }
}
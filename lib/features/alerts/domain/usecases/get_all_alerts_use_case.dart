import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class GetAllAlertsUseCase{
  final AlertRepository repository;

  const GetAllAlertsUseCase({required this.repository});

  Future<List<AlertEntity>> call() async {
    return await repository.getAllAlerts();
  }
}
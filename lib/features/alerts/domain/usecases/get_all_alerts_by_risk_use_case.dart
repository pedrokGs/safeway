import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/enums/alert_risk.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class GetAllAlertsByRiskUseCase{
  final AlertRepository repository;

  const GetAllAlertsByRiskUseCase({required this.repository});

  Future<List<AlertEntity?>> call(AlertRisk risk) async {
    return await repository.getAlertsByRisk(risk);
  }
}
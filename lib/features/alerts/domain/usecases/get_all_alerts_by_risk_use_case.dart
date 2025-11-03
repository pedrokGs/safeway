import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class GetAllAlertsByRiskUseCase{
  final AlertRepository repository;

  const GetAllAlertsByRiskUseCase({required this.repository});

  Future<List<AlertEntity>> call() async {
    throw UnimplementedError();
  }
}
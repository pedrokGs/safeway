import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/enums/alert_type.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class GetAllAlertsByTypeUseCase{
  final AlertRepository repository;

  const GetAllAlertsByTypeUseCase({required this.repository});

  Future<List<AlertEntity>> call(AlertType type) async {
    return await repository.getAlertsByType(type);
  }
}
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class UpdateAlertUseCase{
  final AlertRepository repository;

  const UpdateAlertUseCase({required this.repository});

  Future<AlertEntity> call(AlertEntity entity) async {
    return await repository.updateAlert(entity);
  }
}
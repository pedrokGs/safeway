import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class CreateAlertUseCase{
  final AlertRepository repository;

  const CreateAlertUseCase({required this.repository});

  Future<AlertEntity> call(AlertEntity entity) async {
    throw UnimplementedError();
  }
}
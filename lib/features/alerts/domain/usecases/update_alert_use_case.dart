import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';
import 'package:safeway/features/auth/domain/entities/auth_user_entity.dart';

class UpdateAlertUseCase{
  final AlertRepository repository;

  const UpdateAlertUseCase({required this.repository});

  Future<AuthUserEntity> call(AuthUserEntity entity) async {
    throw UnimplementedError();
  }
}
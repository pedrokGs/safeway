import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class DeleteAlertUseCase{
  final AlertRepository repository;

  const DeleteAlertUseCase({required this.repository});

  Future<void> call(String id) async{
    throw UnimplementedError();
  }
}
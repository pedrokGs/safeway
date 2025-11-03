import 'package:safeway/common/exceptions/invalid_argument_exception.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class DeleteAlertUseCase{
  final AlertRepository repository;

  const DeleteAlertUseCase({required this.repository});

  Future<void> call(String id) async{
    if(id.isEmpty){
      throw InvalidArgumentException();
    }
    await repository.deleteAlertById(id);
  }
}
import 'package:safeway/common/exceptions/invalid_argument_exception.dart';
import 'package:safeway/features/alerts/domain/entities/alert_entity.dart';
import 'package:safeway/features/alerts/domain/repositories/alert_repository.dart';

class CreateAlertUseCase{
  final AlertRepository repository;

  const CreateAlertUseCase({required this.repository});

  Future<AlertEntity> call(AlertEntity entity) async {

    if(entity.data.isAfter(DateTime.now())){
      throw InvalidArgumentException();
    }

    if(entity.titulo.length > 100 || entity.descricao.length > 100){
      throw InvalidArgumentException();
    }

    if(!isWithinRange(entity.latitude, -90, 90)){
      throw InvalidArgumentException();
    }

    if(!isWithinRange(entity.longitude, -180, 180)){
      throw InvalidArgumentException();
    }

    return await repository.createAlert(entity);
  }

  bool isWithinRange(double value, double min, double max){
    return value >= min && value <= max;
  }
}
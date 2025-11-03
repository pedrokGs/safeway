import 'package:safeway/common/exceptions/data_source_exception.dart';

class AlertAlreadyExistsException extends DataSourceException{
  const AlertAlreadyExistsException() : super("Um alerta com esse id já existe");
}
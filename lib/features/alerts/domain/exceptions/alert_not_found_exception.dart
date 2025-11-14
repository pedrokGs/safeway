import 'package:safeway/common/exceptions/data_source_exception.dart';

class AlertNotFoundException extends DataSourceException{
  const AlertNotFoundException() : super("Alerta não foi encontrado");
}
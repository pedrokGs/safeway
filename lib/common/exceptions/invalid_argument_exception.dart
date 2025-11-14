import 'package:safeway/common/exceptions/data_source_exception.dart';

class InvalidArgumentException extends DataSourceException {
  const InvalidArgumentException() : super("Argumentos inválidos");
}
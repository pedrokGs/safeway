import 'package:safeway/common/exceptions/data_source_exception.dart';

class FailedPreconditionException extends DataSourceException{
  const FailedPreconditionException() : super("Pré condição falha");
}
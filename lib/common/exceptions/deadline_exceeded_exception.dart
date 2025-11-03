import 'package:safeway/common/exceptions/data_source_exception.dart';

class DeadlineExceededException extends DataSourceException{
  const DeadlineExceededException() : super("Tempo limite exceedido");
}
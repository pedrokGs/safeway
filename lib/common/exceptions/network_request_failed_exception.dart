import 'data_source_exception.dart';

class NetworkRequestFailedException extends DataSourceException{
  const NetworkRequestFailedException() : super('cant connect to the internet');
}


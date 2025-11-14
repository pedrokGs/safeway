import 'data_source_exception.dart';

class UnauthenticatedException extends DataSourceException{
  const UnauthenticatedException() : super('User is not authenticated');
}


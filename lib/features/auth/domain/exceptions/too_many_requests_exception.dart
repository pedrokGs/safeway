import 'package:safeway/features/auth/domain/exceptions/data_source_exception.dart';

class TooManyRequestsException extends DataSourceException{
  const TooManyRequestsException() : super('too many requests');
}


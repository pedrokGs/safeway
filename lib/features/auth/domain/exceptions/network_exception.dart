import 'package:safeway/features/auth/domain/exceptions/data_source_exception.dart';

class NetworkException extends DataSourceException{
  const NetworkException() : super("Erro de conexão");
}
import 'package:safeway/features/auth/domain/exceptions/data_source_exception.dart';

class InvalidCredentialsException extends DataSourceException{
  const InvalidCredentialsException() : super('Email ou Senha incorretos');
}
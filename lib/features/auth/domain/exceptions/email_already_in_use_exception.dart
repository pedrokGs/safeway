import 'package:safeway/features/auth/domain/exceptions/data_source_exception.dart';

class EmailAlreadyInUseException extends DataSourceException{
  const EmailAlreadyInUseException() : super('Email já está cadastrado no sistema');
}
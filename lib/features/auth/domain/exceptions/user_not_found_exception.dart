import 'package:safeway/features/auth/domain/exceptions/data_source_exception.dart';

class UserNotFoundException extends DataSourceException{
  const UserNotFoundException() : super('usuário não encontrado');
}
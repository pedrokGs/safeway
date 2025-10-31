import 'package:safeway/features/auth/domain/exceptions/data_source_exception.dart';

class UnknownDataSourceException extends DataSourceException {
  final String error;

  const UnknownDataSourceException({this.error = ''})
    : super('Erro inesperado no sistema');
}

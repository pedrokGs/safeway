import 'package:safeway/common/exceptions/data_source_exception.dart';

class PermissionDeniedException extends DataSourceException {
  const PermissionDeniedException() : super("Permissão negada");
}
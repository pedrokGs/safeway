
import '../../../../common/exceptions/data_source_exception.dart';

class GoogleSignInCancelledException extends DataSourceException{
  const GoogleSignInCancelledException() : super('login cancelado');
}
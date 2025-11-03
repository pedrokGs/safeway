
import '../../../../common/exceptions/data_source_exception.dart';

class GoogleSignInFailedException extends DataSourceException{
  const GoogleSignInFailedException() : super('sign in failed');
}


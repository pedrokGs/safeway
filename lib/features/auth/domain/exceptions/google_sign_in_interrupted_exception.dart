
import '../../../../common/exceptions/data_source_exception.dart';

class GoogleSignInInterruptedException extends DataSourceException{
  const GoogleSignInInterruptedException() : super('sign in interrompido');
}


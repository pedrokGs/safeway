import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

import '../exceptions/invalid_credentials_exception.dart';

class SendResetPasswordWithEmailUseCase {
  final AuthRepository repository;

  SendResetPasswordWithEmailUseCase({required this.repository});

  Future<void> call({required String email}) async {
    if (!RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(email)) {
      throw InvalidCredentialsException();
    }

    return await repository.sendResetPasswordEmail(email: email);
  }
}

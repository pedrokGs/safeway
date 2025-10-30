import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/domain/use_cases/send_reset_password_email_use_case.dart';

class PasswordResetState{
  String? errorMessage;
  bool success;
  bool isLoading;

  PasswordResetState({this.errorMessage, this.success = false, this.isLoading = false});
}

class PasswordResetStateNotifier extends Notifier<PasswordResetState>{
  late final SendResetPasswordWithEmailUseCase resetPasswordUseCase;


  @override
  PasswordResetState build() {
    resetPasswordUseCase = ref.watch(sendResetPasswordEmailUseCaseProvider);
    return PasswordResetState();
  }

  Future<void> sendResetPassword({required String email}) async{
    state = PasswordResetState(isLoading: true);
    try{
      await resetPasswordUseCase.call(email: email);
      state = PasswordResetState(isLoading: false, success: true);
    } catch(e){
      state = PasswordResetState(isLoading: false, errorMessage: "Erro deconhecido: $e");
    }
  }
}
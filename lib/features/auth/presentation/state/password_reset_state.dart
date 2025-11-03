import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
import 'package:safeway/common/exceptions/network_request_failed_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/user_not_found_exception.dart';
import 'package:safeway/features/auth/domain/use_cases/send_reset_password_email_use_case.dart';

class PasswordResetState extends Equatable{
  final String? errorMessage;
  final bool success;
  final bool isLoading;

  const PasswordResetState({this.errorMessage, this.success = false, this.isLoading = false});

  @override
  List<Object?> get props => [errorMessage, success, isLoading];
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
    } on NetworkRequestFailedException {
      state = PasswordResetState(isLoading: false, errorMessage: "Verifique sua conexão");
    } on UserNotFoundException{
      state = PasswordResetState(isLoading: false, errorMessage: "Usuário não encontrado");
    } on InvalidCredentialsException{
      state = PasswordResetState(isLoading: false, errorMessage: "Verifique o email");
    } catch(e){
      state = PasswordResetState(isLoading: false, errorMessage: "Erro desconhecido: $e");
    }
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/core/di/auth_providers.dart';
import 'package:safeway/features/auth/domain/exceptions/email_already_in_use_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/google_sign_in_cancelled_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/user_not_found_exception.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_up_with_email_and_password_use_case.dart';

class SignUpState{
  final String? errorMessage;
  final bool isLoading;
  final bool success;

  SignUpState({this.errorMessage, this.isLoading = false, this.success = false});
}

class SignUpStateNotifier extends Notifier<SignUpState>{
  late final SignUpWithEmailAndPasswordUseCase signUpUseCase;
  late final SignInWithGoogleUseCase signinWithGoogleUseCase;

  @override
  SignUpState build() {
    signUpUseCase = ref.watch(signUpWithEmailAndPasswordUseCaseProvider);
    signinWithGoogleUseCase = ref.watch(signInWithGoogleUseCaseProvider);
    return SignUpState();
  }

  Future<void> signUp(String email, String password) async {
    state = SignUpState(isLoading: true);
    try{
      await signUpUseCase.call(email: email, password: password);
      state = SignUpState(isLoading: false, success: true);
    } on InvalidCredentialsException {
      state = SignUpState(isLoading: false, errorMessage: "Credenciais inválidas, verifique a senha e o email");
    } on EmailAlreadyInUseException {
      state = SignUpState(isLoading: false, errorMessage: "Email já está em uso");
    } catch (e) {
      state = SignUpState(isLoading: false, errorMessage: "Erro desconhecido: $e");
    }
  }

  Future<void> signInWithGoogle() async{
    state = SignUpState(isLoading: true);
    try{
      await signinWithGoogleUseCase.call();
      state = SignUpState(isLoading: false, success: true);
    } on InvalidCredentialsException{
      state = SignUpState(isLoading: false, errorMessage: "Credenciais inválidas");
    } on GoogleSignInCancelledException{
      state = SignUpState(isLoading: false, errorMessage: "A entrada foi cancelada");
    } catch(e){
      state = SignUpState(isLoading: false, errorMessage: "Erro deconhecido: $e");
    }
  }
}
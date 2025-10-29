import '../models/auth_user_model.dart';

abstract interface class AuthRemoteDataSource{
  // Getter de Stream para reagir a mudanças de estado de login
  Stream<AuthUserModel?> get authUserChanges;

  // Getter para pegar usuário logado
  AuthUserModel? get currentUser;

  // Tenta fazer login e retorna o ID do usuário encontrado;
  Future<String> signInWithEmailAndPassword({required String email, required String password});

  // Tenta criar uma conta e retorna o ID do usuário criado;
  Future<String> signUpWithEmailAndPassword({required String email, required String password});

  // Tenta fazer sign out e retorna se teve sucesso;
  Future<bool> signOut();

  // Tenta fazer login com google (google_sign_in) e retorna ID do usuário;
  Future<String> signInWithGoogle();

  // Tenta enviar email para resetar password e retorna se teve sucesso;
  Future<bool> sendResetPasswordEmail({required String email});
}
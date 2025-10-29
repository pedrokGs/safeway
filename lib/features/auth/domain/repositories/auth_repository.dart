import 'package:safeway/features/auth/domain/entities/auth_user_entity.dart';

abstract interface class AuthRepository{
  // Getter para Stream de mudança de estado de usuário
  Stream<AuthUserEntity?> get authUserChanges;

  // Getter para usuário atualmente logado
  AuthUserEntity? get currentUser;

  // Envia email e password, retorna o ID do usuário para realizar um fetch info
  Future<String> signInWithEmailAndPassword({required String email, required String password});

  // Envia email e password, retorna o ID do usuário para realizar um fetch info
  Future<String> signUpWithEmailAndPassword({required String email, required String password});

  // Retorna bool (sucesso ou não)
  Future<bool> signOut();

  // Retorna o ID do usuário para realizar um fetch info
  Future<String> signInWithGoogle();

  // Retorna bool (sucesso ou não)
  Future<bool> sendResetPasswordEmail({required String email});

}
// TODO: Riverpod para injeção de dependências
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// -------------------------------------------------------------------
// PASSO 1: O PROVIDER DO FIREBASE (A DEPENDÊNCIA)
// -------------------------------------------------------------------
// Vamos criar um provider simples que apenas nos dá a instância do Firebase Auth.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// -------------------------------------------------------------------
// PASSO 2: A LÓGICA DE AUTENTICAÇÃO (A COISA A TESTAR)
// -------------------------------------------------------------------

// Esta é a "interface" do nosso repositório. Define o que ele DEVE fazer.
abstract class AuthRepository {
  Stream<User?> authStateChanges();
  Future<void> signInWithEmail(String email, String password);
  Future<void> signOut();
}

// Esta é a implementação "concreta" que usa o Firebase.
class FirebaseAuthRepository implements AuthRepository {
  // A classe pede pelo FirebaseAuth (nossa dependência)
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRepository(this._firebaseAuth);

  @override
  Stream<User?> authStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  @override
  Future<void> signInWithEmail(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }
}

// -------------------------------------------------------------------
// PASSO 3: O PROVIDER DA LÓGICA (A INJEÇÃO DE DEPENDÊNCIA)
// -------------------------------------------------------------------

// Este é o provider que seu app vai usar.
// Ele usa 'ref.watch' para pegar o provider do Firebase (Passo 1)
// e o "injeta" no nosso FirebaseAuthRepository (Passo 2).
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepository(firebaseAuth);
});

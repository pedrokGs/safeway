import 'package:firebase_auth/firebase_auth.dart';
import 'package:safeway/features/auth/data/models/auth_user_model.dart';
import 'package:safeway/features/auth/domain/exceptions/data_source_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/network_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/unkonwn_data_source_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/user_not_found_exception.dart';

import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceFirebase implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceFirebase({required this.firebaseAuth});

  @override
  Stream<AuthUserModel?> get authUserChanges =>
      firebaseAuth.authStateChanges().map((user) {
        if (user == null) return null;
        return AuthUserModel(email: user.email!, id: user.uid);
      });

  @override
  AuthUserModel? get currentUser {
    final user = firebaseAuth.currentUser;
    if (user == null) return null;
    return AuthUserModel(email: user.email!, id: user.uid);
  }

  @override
  Future<void> sendResetPasswordEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') throw UserNotFoundException();
      if (e.code == 'invalid-credentials') throw InvalidCredentialsException();
      if (e.code == 'network-error') throw NetworkException();
      throw DataSourceException('Datasource error: ${e.code}');
    } catch (e) {
      throw UnknownDataSourceException(error: e.toString());
    }
  }

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    // TODO: implement signInWithEmailAndPassword
    throw UnimplementedError();
  }

  @override
  Future<String> signInWithGoogle() {
    // TODO: implement signInWithGoogle
    throw UnimplementedError();
  }

  @override
  Future<bool> signOut() {
    // TODO: implement signOut
    throw UnimplementedError();
  }

  @override
  Future<String> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    // TODO: implement signUpWithEmailAndPassword
    throw UnimplementedError();
  }
}

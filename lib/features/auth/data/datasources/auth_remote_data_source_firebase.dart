import 'package:firebase_auth/firebase_auth.dart';
import 'package:safeway/features/auth/data/models/auth_user_model.dart';

import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceFirebase implements AuthRemoteDataSource{
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceFirebase({required this.firebaseAuth});

  @override
  // TODO: implement authUserChanges
  Stream<AuthUserModel?> get authUserChanges => throw UnimplementedError();

  @override
  // TODO: implement currentUser
  AuthUserModel? get currentUser => throw UnimplementedError();

  @override
  Future<bool> sendResetPasswordEmail({required String email}) {
    // TODO: implement sendResetPasswordEmail
    throw UnimplementedError();
  }

  @override
  Future<String> signInWithEmailAndPassword({required String email, required String password}) {
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
  Future<String> signUpWithEmailAndPassword({required String email, required String password}) {
    // TODO: implement signUpWithEmailAndPassword
    throw UnimplementedError();
  }

}
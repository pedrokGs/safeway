import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:safeway/features/auth/data/models/auth_user_model.dart';
import 'package:safeway/common/exceptions/data_source_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/email_already_in_use_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/google_sign_in_cancelled_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/google_sign_in_failed_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/google_sign_in_interrupted_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/invalid_credentials_exception.dart';
import 'package:safeway/common/exceptions/network_request_failed_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/too_many_requests_exception.dart';
import 'package:safeway/common/exceptions/unknown_data_source_exception.dart';
import 'package:safeway/features/auth/domain/exceptions/user_not_found_exception.dart';

import 'auth_remote_data_source.dart';

class AuthRemoteDataSourceFirebase implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceFirebase({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

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
      if (e.code == 'user-not-found') {
        throw UserNotFoundException();
      }
      if (e.code == 'invalid-credentials') {
        throw InvalidCredentialsException();
      }
      if (e.code == 'network-request-failed') {
        throw NetworkRequestFailedException();
      }
      throw DataSourceException('Datasource error: ${e.code}');
    } catch (e) {
      throw UnknownDataSourceException(error: e.toString());
    }
  }

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credentials = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      if (credentials.user == null) {
        throw Exception(); // TODO: Melhorar isso aqui depois
      }
      return credentials.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') throw UserNotFoundException();
      if (e.code == 'invalid-credentials') throw InvalidCredentialsException();
      if (e.code == 'network-request-failed') {
        throw NetworkRequestFailedException();
      }
      if (e.code == 'too-many-requests') throw TooManyRequestsException();
      throw DataSourceException('Datasource error: ${e.code}');
    } catch (e) {
      throw UnknownDataSourceException(error: "Unkown error: $e");
    }
  }

  @override
  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredentials = await firebaseAuth.signInWithCredential(
        credential,
      );
      return userCredentials.user!.uid;

    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw GoogleSignInCancelledException();
      }
      if (e.code == GoogleSignInExceptionCode.interrupted) {
        throw GoogleSignInInterruptedException();
      }
      if (e.code == GoogleSignInExceptionCode.clientConfigurationError ||
          e.code == GoogleSignInExceptionCode.providerConfigurationError) {
        throw GoogleSignInFailedException();
      }
      throw DataSourceException("Google Sign in Error: ${e.code}");
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw NetworkRequestFailedException();
      }
      if (e.code == 'too-many-requests') {
        throw TooManyRequestsException();
      }
      throw DataSourceException("Datasource Exception: ${e.code}");
    } catch (e) {
      throw UnknownDataSourceException(error: "Unknown Error: $e");
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw NetworkRequestFailedException();
      }
      throw DataSourceException('Datasource error: $e');
    } catch (e) {
      throw UnknownDataSourceException(error: 'Unknown Error: $e');
    }
  }

  @override
  Future<String> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credentials = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      if (credentials.user == null) {
        throw Exception(); // TODO: Melhorar isso aqui depois
      }
      return credentials.user!.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseException();
      }
      if (e.code == 'invalid-credentials') {
        throw InvalidCredentialsException();
      }
      if (e.code == 'network-request-failed') {
        throw NetworkRequestFailedException();
      }
      if (e.code == 'too-many-requests') throw TooManyRequestsException();
      throw DataSourceException('Datasource error: ${e.code}');
    } catch (e) {
      throw UnknownDataSourceException(error: "Unkown error: $e");
    }
  }
}

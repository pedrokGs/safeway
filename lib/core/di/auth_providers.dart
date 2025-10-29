import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safeway/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:safeway/features/auth/data/datasources/auth_remote_data_source_firebase.dart';
import 'package:safeway/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';
import 'package:safeway/features/auth/domain/use_cases/send_reset_password_email_use_case.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_in_with_email_and_password_use_case.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:safeway/features/auth/domain/use_cases/sign_up_with_email_and_password_use_case.dart';

// Data
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance,);
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) => AuthRemoteDataSourceFirebase(firebaseAuth: ref.watch(firebaseAuthProvider)),);
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(dataSource: ref.watch(authRemoteDataSourceProvider)),);

// Use Cases
final signInWithEmailAndPasswordUseCaseProvider = Provider<SignInWithEmailAndPasswordUseCase>((ref) => SignInWithEmailAndPasswordUseCase(repository: ref.watch(authRepositoryProvider)),);
final signUpWithEmailAndPasswordUseCaseProvider = Provider<SignUpWithEmailAndPasswordUseCase>((ref) => SignUpWithEmailAndPasswordUseCase(repository: ref.watch(authRepositoryProvider)));
final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) => SignInWithGoogleUseCase(repository: ref.watch(authRepositoryProvider)));
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) => SignOutUseCase(repository: ref.watch(authRepositoryProvider)));
final sendResetPasswordEmailUseCaseProvider = Provider<SendResetPasswordWithEmailUseCase>((ref) => SendResetPasswordWithEmailUseCase(repository: ref.watch(authRepositoryProvider)));
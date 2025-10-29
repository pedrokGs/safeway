import 'package:safeway/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:safeway/features/auth/domain/entities/auth_user_entity.dart';
import 'package:safeway/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Stream<AuthUserEntity?> get authUserChanges =>
      dataSource.authUserChanges.map((user) {
        if (user == null) return null;
        return AuthUserEntity(id: user.id!, email: user.email);
      });

  @override
  AuthUserEntity? get currentUser {
    final user = dataSource.currentUser;
    if (user == null) return null;
    return user.toEntity();
  }

  @override
  Future<bool> sendResetPasswordEmail({required String email}) async {
    return await dataSource.sendResetPasswordEmail(email: email);
  }

  @override
  Future<String> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await dataSource.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<String> signInWithGoogle() async {
    return await dataSource.signInWithGoogle();
  }

  @override
  Future<bool> signOut() async {
    return await dataSource.signOut();
  }

  @override
  Future<String> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await dataSource.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );
  }
}

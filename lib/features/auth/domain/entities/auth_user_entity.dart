import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable{
  final String id;
  final String email;

  const AuthUserEntity({required this.id, required this.email});

  AuthUserEntity copyWith({String? id, String? email}) => AuthUserEntity(id: id ?? this.id, email: email ?? this.email);

  factory AuthUserEntity.empty() => AuthUserEntity(id: '', email: '');

  bool get isEmpty => id.isEmpty && email.isEmpty;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [id, email];
}


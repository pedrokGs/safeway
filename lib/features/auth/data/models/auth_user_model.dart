import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safeway/features/auth/domain/entities/auth_user_entity.dart';

part 'auth_user_model.g.dart';

@JsonSerializable()
class AuthUserModel extends Equatable{
  final String? id;
  final String email;

  const AuthUserModel({this.id, required this.email});

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => _$AuthUserModelFromJson(json);
  Map<String, dynamic> toJson() => _$AuthUserModelToJson(this);

  AuthUserModel copyWith({String? id, String? email}) => AuthUserModel(id: id ?? this.id, email: email ?? this.email);

  AuthUserEntity toEntity() => AuthUserEntity(id: id ?? '', email: email);

  factory AuthUserModel.empty() => const AuthUserModel(id: null, email: '');

  @override
  List<Object?> get props => [id, email];
}
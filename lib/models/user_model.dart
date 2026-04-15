import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserRole { user, admin, owner }

@JsonSerializable()
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String phoneNumber;
  final String photoUrl;
  final UserRole role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phoneNumber,
    this.photoUrl = '',
    this.role = UserRole.user,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? phoneNumber,
    String? photoUrl,
    UserRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() => 'UserModel(uid: $uid, email: $email, name: $name, role: $role)';
}

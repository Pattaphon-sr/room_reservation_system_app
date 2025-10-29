// lib/core/auth/auth_models.dart
enum UserRole { user, staff, approver }

class AuthUser {
  final String email;
  final UserRole role;
  const AuthUser(this.email, this.role);
}

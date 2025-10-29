import 'package:room_reservation_system_app/core/routes/roles.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  /// DEMO: ส่ง role ตามอีเมล
  /// - ...@user.com  => Role.user
  /// - ...@staff.com => Role.staff
  /// - ...@approver.com => Role.approver
  Future<Role?> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 350));
    if (email.endsWith('@user.com')) return Role.user;
    if (email.endsWith('@staff.com')) return Role.staff;
    if (email.endsWith('@approver.com')) return Role.approver;
    return null;
  }
}

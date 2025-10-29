import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/routes/roles.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/features/approver/root.dart';
import 'package:room_reservation_system_app/features/staff/root.dart';
import 'package:room_reservation_system_app/features/user/root.dart';
import 'package:room_reservation_system_app/services/auth_service.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/features/auth/auth.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    setState(() {
      loading = true;
    });
    final role = await AuthService.instance.login(
      email: emailCtrl.text.trim(),
      password: passCtrl.text,
    );
    setState(() => loading = false);

    if (role == null) {
      return;
    }

    Widget dest;
    switch (role) {
      case Role.user:
        dest = const UserRoot();
        break;
      case Role.staff:
        dest = const StaffRoot();
        break;
      case Role.approver:
        dest = const ApproverRoot();
        break;
    }

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => dest), (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryGradient2C),
        ),
        child: SafeArea(
          child: Container(
            width: size.width,
            height: size.height,
            color: Colors.transparent,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 32),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 60),
                            Text(
                              'Hello',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              'Sign in!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: size.width,
                      height: size.height * 0.7,
                      decoration: ShapeDecoration(
                        color: Color(0xFFEEEEEE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: AppShapes.radiusXxl,
                            topRight: AppShapes.radiusXxl,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 42),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 40),
                            // Spacer(),
                            TextField(
                              controller: emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F828C),
                                ),
                                floatingLabelStyle: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F828C),
                                ),
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                labelText: 'Gmail',
                                hintText: 'user@gmail.com',
                              ),
                            ),
                            SizedBox(height: 14),
                            TextField(
                              controller: passCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F828C),
                                ),
                                floatingLabelStyle: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0F828C),
                                ),
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                labelText: 'Password',
                                hintText: 'your password',
                              ),
                            ),
                            Spacer(flex: 2),
                            AppButton.solid(
                              label: loading ? 'SIGNING IN...' : 'SIGN IN',
                              onPressed: loading ? null : _doLogin,
                            ),
                            Spacer(flex: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Don’t have account?',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign up',
                                    style: TextStyle(
                                      color: Color(0xFF0F828C),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 44),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

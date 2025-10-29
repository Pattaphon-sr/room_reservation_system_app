import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/routes/roles.dart';
import 'package:room_reservation_system_app/features/approver/root.dart';
import 'package:room_reservation_system_app/features/staff/root.dart';
import 'package:room_reservation_system_app/features/user/root.dart';
import 'package:room_reservation_system_app/services/auth_service.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

/// ===== InitialScreen (ของจริงคุณ) + onPressed เชื่อมไป SignIn/SignUp =====
class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});
  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: AppColors.primaryGradient2C),
        ),
        child: SafeArea(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              children: [
                const Spacer(flex: 2),
                Image.network(
                  'https://img.icons8.com/?size=100&id=4CN4ze8gbufE&format=png&color=FFFFFF',
                  scale: 1.2,
                ),
                const Spacer(),
                Container(
                  width: size.width,
                  height: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 42),
                  child: Column(
                    children: [
                      const Text(
                        'Cubbyhole',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      AppButton.outline(
                        label: 'SIGN IN',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignInScreen(),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      AppButton.solid(
                        label: 'SIGN UP',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SignUpScreen(),
                            ),
                          );
                        },
                        backgroundColor: const Color(0xFFEBEBEB),
                        foregroundColor: Colors.black,
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
                Text(
                  'Group 2 Project B',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ===== SignInScreen (ของจริงคุณ) + login แล้วไป Root ตาม role =====
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  String? err;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    setState(() {
      loading = true;
      err = null;
    });
    final role = await AuthService.instance.login(
      email: emailCtrl.text.trim(),
      password: passCtrl.text,
    );
    setState(() => loading = false);

    if (role == null) {
      setState(
        () => err =
            'Email หรือ Password ไม่ถูกต้อง (ลอง …@user.com / …@staff.com / …@approver.com)',
      );
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
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
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
                    color: const Color(0xFFEEEEEE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: AppShapes.radiusXxl,
                        topRight: AppShapes.radiusXxl,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 42),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        TextField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F828C),
                            ),
                            floatingLabelStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F828C),
                            ),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            labelText: 'Gmail',
                            hintText:
                                'me@user.com / me@staff.com / me@approver.com',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: passCtrl,
                          textInputAction: TextInputAction.done,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F828C),
                            ),
                            floatingLabelStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F828C),
                            ),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            labelText: 'Password',
                            hintText: 'your password',
                          ),
                        ),
                        const Spacer(flex: 2),
                        AppButton.solid(
                          label: loading ? 'SIGNING IN...' : 'SIGN IN',
                          onPressed: loading ? null : _doLogin,
                        ),
                        const Spacer(flex: 2),
                        if (err != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              err!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
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
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
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
                        const SizedBox(height: 44),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ===== SignUpScreen (ของจริงคุณ) — demo ปุ่มยังไม่ผูก backend =====
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    super.dispose();
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
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(width: 32),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SizedBox(height: 60),
                        Text(
                          'Create',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Account',
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
                    color: const Color(0xFFEEEEEE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: AppShapes.radiusXxl,
                        topRight: AppShapes.radiusXxl,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 42),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        TextField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F828C),
                            ),
                            floatingLabelStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F828C),
                            ),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            labelText: 'Gmail',
                            hintText: 'user@gmail.com',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: nameCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F828C),
                            ),
                            floatingLabelStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F828C),
                            ),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            labelText: 'Username',
                            hintText: 'username',
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: passCtrl,
                          textInputAction: TextInputAction.done,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F828C),
                            ),
                            floatingLabelStyle: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0F828C),
                            ),
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            labelText: 'Password',
                            hintText: 'your password',
                          ),
                        ),
                        const Spacer(flex: 2),
                        AppButton.solid(
                          label: 'SIGN UP',
                          onPressed: () {
                            Navigator.of(context).pop(); // กลับไปหน้า Sign In
                          },
                        ),
                        const Spacer(flex: 3),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  color: Color(0xFF0F828C),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

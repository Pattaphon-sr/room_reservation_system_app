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
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    // ถ้ายังกรอกไม่ครบ / ไม่ผ่าน validator → แจ้งเตือนและไม่ไปต่อ
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final id = emailCtrl.text.trim();
      final pass = passCtrl.text;
      final looksLikeEmail = id.contains('@');

      final role = await AuthService.instance.login(
        email: looksLikeEmail ? id : null,
        username: looksLikeEmail ? null : id,
        password: pass,
      );

      setState(() => loading = false);

      if (role == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
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
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => dest),
        (_) => false,
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
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
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 40),
                              // Spacer(),
                              TextFormField(
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
                                validator: (v) {
                                  final text = v?.trim() ?? '';
                                  if (text.isEmpty)
                                    return 'Please enter your email.';
                                  if (text.contains('@')) {
                                    final emailOk = RegExp(
                                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                    ).hasMatch(text);
                                    if (!emailOk) return 'Invalid email format';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 14),
                              TextFormField(
                                controller: passCtrl,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _obscure,
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
                                  suffixIcon: IconButton(
                                    // <- ปุ่มสลับโชว์/ซ่อน
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: const Color(0xFF0F828C),
                                      size: 22,
                                    ),
                                  ),
                                ),
                                validator: (v) {
                                  if ((v ?? '').isEmpty)
                                    return 'Please enter your password.';
                                  return null;
                                },
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

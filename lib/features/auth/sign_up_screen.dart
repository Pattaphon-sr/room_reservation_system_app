import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/services/auth_service.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/features/auth/auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // เพิ่ม GlobalKey สำหรับ Form
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();
  bool _obscure = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับ Sign Up
  Future<void> _doSignUp() async {
    // ตรวจสอบความถูกต้องของข้อมูลใน Form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; // ถ้าไม่ถูกต้อง, ไม่ทำต่อ
    }

    // ถ้าข้อมูลถูกต้อง, ดำเนินการต่อ
    final email = emailCtrl.text.trim();
    final username = nameCtrl.text.trim();
    final pass = passCtrl.text;

    final err = await AuthService.instance.signup(
      email: email,
      username: username,
      password: pass,
    );
    if (!mounted) return;
    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Signup successful. Please sign in.',
          ),
        ),
      );
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const SignInScreen(),
      ),
    );
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
                        // เพิ่ม widget Form และกำหนด key
                        child: Form(
                          key: _formKey,
                          // ตั้งค่าให้ validate อัตโนมัติเมื่อผู้ใช้พิมพ์
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 40),
                              // เปลี่ยนจาก TextField เป็น TextFormField
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
                                // เพิ่ม validator
                                validator: (v) {
                                  final text = v?.trim() ?? '';
                                  if (text.isEmpty)
                                    return 'Please enter your email.';
                                  // ลบการเช็ค Email format ออก
                                  return null;
                                },
                              ),
                              SizedBox(height: 14),
                              // เปลี่ยนจาก TextField เป็น TextFormField
                              TextFormField(
                                controller: nameCtrl,
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
                                  labelText: 'Username',
                                  hintText: 'username',
                                ),
                                // เพิ่ม validator
                                validator: (v) {
                                  if ((v?.trim() ?? '').isEmpty) {
                                    return 'Please enter your username.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 14),
                              // เปลี่ยนจาก TextField เป็น TextFormField
                              TextFormField(
                                controller: passCtrl,
                                textInputAction: TextInputAction.next,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _obscure,
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
                                // เพิ่ม validator
                                validator: (v) {
                                  if ((v ?? '').isEmpty) {
                                    return 'Please enter your password.';
                                  }
                                  // ลบการเช็คความยาว Password ออก
                                  return null;
                                },
                              ),
                              SizedBox(height: 14),
                              // เปลี่ยนจาก TextField เป็น TextFormField
                              TextFormField(
                                controller: pass2Ctrl,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _obscure2,
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
                                  labelText: 'Confirm Password',
                                  hintText: 'your password',
                                  suffixIcon: IconButton(
                                    onPressed: () =>
                                        setState(() => _obscure2 = !_obscure2),
                                    icon: Icon(
                                      _obscure2
                                          ? Icons.visibility_off_rounded
                                          : Icons.visibility_rounded,
                                      color: const Color(0xFF0F828C),
                                      size: 22,
                                    ),
                                  ),
                                ),
                                // เพิ่ม validator
                                validator: (v) {
                                  if ((v ?? '').isEmpty) {
                                    return 'Please confirm your password.';
                                  }
                                  // ลบการเช็ค Password match ออก
                                  return null;
                                },
                              ),
                              Spacer(flex: 2),
                              AppButton.solid(
                                label: 'SIGN UP',
                                // เรียกใช้ _doSignUp เมื่อกดปุ่ม
                                onPressed: _doSignUp,
                              ),
                              Spacer(flex: 3),
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
                                  SizedBox(width: 12),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const SignInScreen(),
                                        ),
                                      );
                                    },
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
                              SizedBox(height: 50),
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
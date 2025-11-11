import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/services/auth_service.dart';
// ⭐️ import "showAirDialog" (มีอยู่แล้ว)
import 'package:room_reservation_system_app/shared/widgets/widgets.dart'; 
import 'package:room_reservation_system_app/features/auth/auth.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final pass2Ctrl = TextEditingController();
  bool _obscure = true;
  bool _obscure2 = true;

  bool _loading = false; 

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    pass2Ctrl.dispose();
    super.dispose();
  }

  // ⭐️ [FIX] แก้ไข _doSignUp ให้เรียกใช้ "showAirDialog"
  Future<void> _doSignUp() async {
    // 1. ตรวจสอบ Form
    if (!(_formKey.currentState?.validate() ?? false)) {
      return; 
    }

    setState(() => _loading = true); // ⬅️ เริ่ม Loading

    String? errMessage; // ⬅️ ตัวแปรเก็บ Error (ถ้ามี)

    try {
      // 2. เรียก AuthService
      errMessage = await AuthService.instance.signup(
        email: emailCtrl.text.trim(),
        username: nameCtrl.text.trim(),
        password: passCtrl.text,
      );
    } catch (e) {
      // 3. ถ้า Error (เช่น ต่อเน็ตไม่ได้)
      errMessage = e.toString();
    }

    if (!mounted) return;

    // 4. หยุด Loading "ก่อน" ที่จะโชว์ Dialog หรือ SnackBar
    setState(() => _loading = false);

    // 5. จัดการผลลัพธ์
    if (errMessage == null) {
      // 6. ⭐️ [NEW] ถ้าสำเร็จ ➔ โชว์ "showAirDialog"
      await showAirDialog(
        context,
        height: 300,
        dismissible: false, // บังคับให้กด OK
        title: null, // เราจะใช้ content ใส่ Icon แทน
        
        // ⭐️ [NEW] ใส่ Icon และ Text ใน Content
        content: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, size: 68, color: Colors.lightGreenAccent),
            SizedBox(height: 24),
            Text(
              "Success!",
              style: TextStyle(
                color: Colors.white, // ⬅️ showAirDialog ใช้ Text สีขาว
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Signup successful.\nPlease sign in.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),

        // ⭐️ [NEW] ใส่ปุ่ม OK ใน Actions
        actions: [
          Center(
            child: SizedBox(
              width: 120,
              child: AppButton.solid( 
                label: 'OK',
                onPressed: () {
                  Navigator.of(context).pop(); // ⬅️ ปิด Pop-up
                },
              ),
            ),
          )
        ],
      );

      // 7. "หลังจาก" กด OK แล้ว ค่อยเด้งกลับไปหน้า Login
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const SignInScreen(),
        ),
      );

    } else {
      // 8. ถ้าไม่สำเร็จ (มี Error Message กลับมา) ➔ โชว์ SnackBar แดง
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signup failed: $errMessage'),
          backgroundColor: Colors.red,
        ),
      );
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
                    // ... (ส่วน "Create Account" เหมือนเดิม)
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
                      // ⭐️ [FIX] ใช้ SingleChildScrollView
                      child: Form(
                        key: _formKey,
                        // ⭐️ [FIX] เปลี่ยนเป็น .disabled
                        autovalidateMode: AutovalidateMode.disabled,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(horizontal: 42),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 40),
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
                                  // เช็ก format email
                                  final emailOk = RegExp(
                                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                      .hasMatch(text);
                                  if (!emailOk) return 'Invalid email format';
                                  return null;
                                },
                              ),
                              SizedBox(height: 14),
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
                                validator: (v) {
                                  if ((v?.trim() ?? '').isEmpty) {
                                    return 'Please enter your username.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 14),
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
                                validator: (v) {
                                  if ((v ?? '').isEmpty) {
                                    return 'Please enter your password.';
                                  }
                                  if (v!.length < 6) {
                                    return 'Password must be at least 6 characters.';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 14),
                              TextFormField(
                                controller: pass2Ctrl,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText: _obscure2,
                                onFieldSubmitted: (_) { 
                                  if (_loading) return;
                                  _doSignUp();
                                },
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
                                validator: (v) {
                                  if ((v ?? '').isEmpty) {
                                    return 'Please confirm your password.';
                                  }
                                  if (v != passCtrl.text) {
                                    return 'Passwords do not match.';
                                  }
                                  return null;
                                },
                              ),
                              
                              // ⭐️ [FIX] เปลี่ยน Spacer เป็น SizedBox
                              SizedBox(height: 30),

                              AppButton.solid(
                                label: _loading ? 'SIGNING UP...' : 'SIGN UP',
                                onPressed: _loading ? null : _doSignUp,
                              ),
                              
                              // ⭐️ [FIX] เปลี่ยน Spacer เป็น SizedBox
                              SizedBox(height: 30),
                              
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
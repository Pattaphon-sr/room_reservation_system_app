import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/features/auth/auth.dart';
// ตรวจสอบว่า path ไปยัง AuthService ถูกต้อง
import 'package:room_reservation_system_app/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final nameCtrl = TextEditingController(); // Controller สำหรับ Username
  final confirmPassCtrl =
      TextEditingController(); // Controller สำหรับ Confirm Password

  bool loading = false; // เพิ่ม state loading
  bool _obscure = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    nameCtrl.dispose();
    confirmPassCtrl.dispose(); // อย่าลืม dispose
    super.dispose();
  }

  // --- เพิ่มฟังก์ชันนี้ ---
  Future<void> _doSignUp() async {
    // 1. ตรวจสอบว่ารหัสผ่านตรงกัน
    if (passCtrl.text != confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 2. ตรวจสอบว่ากรอกครบ
    if (emailCtrl.text.isEmpty ||
        nameCtrl.text.isEmpty ||
        passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => loading = true);

    // 3. เรียก AuthService
    final success = await AuthService.instance.signup(
      email: emailCtrl.text.trim(),
      username: nameCtrl.text.trim(),
      password: passCtrl.text,
    );

    setState(() => loading = false);

    if (success) {
      // 4. ถ้าสำเร็จ กลับไปหน้า Login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup successful! Please sign in.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const SignInScreen(),
          ),
        );
      }
    } else {
      // 5. ถ้าไม่สำเร็จ (เช่น email ซ้ำ)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup failed. Email or username may already exist.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  // -------------------------

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
                      // --- ใช้ SingleChildScrollView กันคีย์บอร์ดบัง ---
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 42),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: 40),
                            TextField(
                              controller: emailCtrl, // ผูก Controller
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                // ... (style เหมือนเดิม) ...
                                labelText: 'Gmail',
                                hintText: 'user@gmail.com',
                              ),
                            ),
                            SizedBox(height: 14),
                            TextField(
                              controller: nameCtrl, // <--- แก้ไข: ผูก nameCtrl
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                // ... (style เหมือนเดิม) ...
                                labelText: 'Username',
                                hintText: 'username',
                              ),
                            ),
                            SizedBox(height: 14),
                            TextField(
                              controller: passCtrl, // ผูก Controller
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                // ... (style เหมือนเดิม) ...
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
                            ),
                            SizedBox(height: 14),
                            TextField(
                              controller:
                                  confirmPassCtrl, // <--- แก้ไข: ผูก confirmPassCtrl
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: _obscure2,
                              decoration: InputDecoration(
                                // ... (style เหมือนเดิม) ...
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
                            ),
                            SizedBox(height: 30), // ลด Space ลงหน่อย
                            AppButton.solid(
                              label: loading
                                  ? 'SIGNING UP...'
                                  : 'SIGN UP', // <--- แก้ไข
                              onPressed: loading
                                  ? null
                                  : _doSignUp, // <--- แก้ไข: เรียก _doSignUp
                            ),
                            SizedBox(height: 30), // ลด Space ลงหน่อย
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
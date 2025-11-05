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
                            ),
                            SizedBox(height: 14),
                            TextField(
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
                            ),
                            SizedBox(height: 14),
                            TextField(
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
                                  // <- ปุ่มสลับโชว์/ซ่อน
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
                            Spacer(flex: 2),
                            AppButton.solid(
                              label: 'SIGN UP',
                              onPressed: () async {
                                final email = emailCtrl.text.trim();
                                final username = nameCtrl.text.trim();
                                final pass = passCtrl.text;
                                final pass2 = pass2Ctrl.text;

                                if (email.isEmpty ||
                                    username.isEmpty ||
                                    pass.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill all fields'),
                                    ),
                                  );
                                  return;
                                }

                                if (email.isEmpty ||
                                    username.isEmpty ||
                                    pass.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill all fields'),
                                    ),
                                  );
                                  return;
                                }

                                if (pass != pass2) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Passwords do not match'),
                                    ),
                                  );
                                  return;
                                }

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
                              },
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

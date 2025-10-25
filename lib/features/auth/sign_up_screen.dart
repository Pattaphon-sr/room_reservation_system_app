import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

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
      body: SafeArea(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: AppColors.primaryGradient),
          ),
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
                      padding: EdgeInsetsGeometry.symmetric(horizontal: 42),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 40),
                          // Spacer(),
                          TextField(
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
                          SizedBox(height: 14),
                          TextField(
                            textInputAction: TextInputAction.done,
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
                            ),
                          ),
                          Spacer(flex: 2),
                          AppButton.solid(label: 'SIGN UP', onPressed: () {}),
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
                                onTap: () {},
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
    );
  }
}

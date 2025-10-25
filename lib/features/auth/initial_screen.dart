import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});
  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
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
                  children: [
                    Spacer(flex: 2),
                    Image.network(
                      'https://img.icons8.com/?size=100&id=4CN4ze8gbufE&format=png&color=FFFFFF',
                      scale: 1.2,
                    ),
                    Spacer(),
                    Container(
                      width: size.width,
                      height: 200,
                      padding: EdgeInsets.symmetric(horizontal: 42),
                      child: Column(
                        children: [
                          Text(
                            'Cubbyhole',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Spacer(),
                          AppButton.outline(label: 'SIGN IN', onPressed: () {}),
                          Spacer(),
                          AppButton.solid(
                            label: 'SIGN UP',
                            onPressed: () {},
                            backgroundColor: Color(0xFFEBEBEB),
                            foregroundColor: Colors.black,
                          ),
                        ],
                      ),
                    ),
                    Spacer(flex: 2),
                    Text(
                      'Group 2 Project B',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Spacer(flex: 1),
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

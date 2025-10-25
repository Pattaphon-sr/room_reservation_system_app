import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool _skyExpanded = false;

  double get _skyHeight => _skyExpanded ? 260 : 160; // สูงตอนขยาย/หด

  void showAlert(BuildContext context) async {
    await showAirDialog(
      context,
      title: 'Delete room?',
      message: 'This action will archive the room and keep its history.',
      actions: [
        AppButton.outline(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        AppButton.solid(
          label: 'Confirm',
          onPressed: () {
            /* do something */
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient5C,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: AppColorStops.primaryStop5C,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 26),

                  // PINK (คงเดิม)
                  PanelPresets.pink(
                    width: 300,
                    height: 160,
                    child: const Center(
                      child: Text(
                        'Figma-like Panel2',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // PURPLE (คงเดิม)
                  PanelPresets.purple(
                    width: 300,
                    height: 160,
                    child: const Center(
                      child: Text(
                        'Figma-like Panel2',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  // SKY (ใส่อนิเมชันขยายแนวตั้ง + เปลี่ยนข้อความเป็น test)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _skyExpanded = !_skyExpanded),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      // ให้ parent สูงตามอนิเมชัน เพื่อไม่กระชาก layout
                      height: _skyHeight,
                      width: 300,
                      child: PanelPresets.sky(
                        width: 300,
                        height: _skyHeight, // แจ้งความสูงให้ panel ด้วย
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, anim) =>
                                FadeTransition(opacity: anim, child: child),
                            child: Text(
                              _skyExpanded ? 'test' : 'Figma-like Panel2',
                              key: ValueKey(_skyExpanded),
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  AppButton.solid(
                    label: 'label',
                    onPressed: () => showAlert(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

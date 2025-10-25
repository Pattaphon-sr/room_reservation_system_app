import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/core/theme/app_colors.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

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
          begin: AlignmentGeometry.topCenter,
          end: AlignmentDirectional.bottomCenter,
          stops: AppColorStops.primaryStop5C,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 50, child: Container(color: Colors.transparent)),
              PanelPresets.pink(
                width: 300,
                height: 160,
                child: Center(
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
              SizedBox(height: 50, child: Container(color: Colors.transparent)),
              PanelPresets.purple(
                width: 300,
                height: 160,
                child: Center(
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
              SizedBox(height: 50, child: Container(color: Colors.transparent)),
              PanelPresets.sky(
                width: 300,
                height: 160,
                child: Center(
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
              SizedBox(height: 50, child: Container(color: Colors.transparent)),
              AppButton.solid(
                label: 'label',
                onPressed: () => showAlert(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

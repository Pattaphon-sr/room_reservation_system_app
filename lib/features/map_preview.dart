import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/data/cells_seed.dart';
import 'package:room_reservation_system_app/core/theme/theme.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';
import 'package:room_reservation_system_app/shared/widgets/maps/map_types.dart';

class MapPreview extends StatefulWidget {
  const MapPreview({super.key});

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  // สมมุติผู้ใช้ปัจจุบัน และช่วงเวลาที่เลือกจาก dropdown ด้านบน
  final String _currentUsername = 'User123';
  final String _selectedSlot = '08:00 - 10:00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roomBlue,
      body: Center(
        child: MapFloor(
          floor: 5,
          slotId: 'S1',
          role: MapRole.staff,
          cells: kCellsAll,
          onCellTap: (x, y, cell) {
            // debugPrint('tap ($x,$y) ${cell['type']} ${cell['roomNo'] ?? ''}');
            _showBookingPopup(cell);
          },
        ),
      ),
    );
  }

  Future<void> _showBookingPopup(Map<String, dynamic> cell) async {
    final String roomNo = (cell['roomNo'] ?? '-').toString();
    final String byUser = _currentUsername;
    final String slotLabel = _selectedSlot;

    await showAirDialog(
      context,
      height: 400,
      // ถ้าอยากไม่มี title ก็ปล่อยว่าง
      title: null,
      content: SizedBox(
        height: 354,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 66),
                  _popupRow(label: 'Room', value: roomNo),
                  const SizedBox(height: 12),
                  _popupRow(label: 'Time', value: slotLabel),
                  const SizedBox(height: 12),
                  _popupRow(label: 'By', value: byUser),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppButton.solid(
                  label: 'Confirm',
                  onPressed: () async {
                    // ปิด popup ยืนยันก่อน
                    Navigator.pop(context);

                    // === 2) ยิง API สร้างคำขอจอง (status = pending) (จำลอง) ===
                    // await reservationApi.createPending(roomNo, slotLabel, byUser);
                    final ok = await _submitReservation(
                      roomNo: roomNo,
                      slot: slotLabel,
                      user: byUser,
                    );

                    await Future.delayed(const Duration(milliseconds: 120));

                    // === 3) โชว์Result (auto-close 5 s.) ===
                    await _showResultPopup(ok: ok);
                  },
                ),
                const SizedBox(height: 14),
                AppButton.outline(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: const [SizedBox.shrink()],
    );
  }

  // === 2) ฟังก์ชันจำลองการยิง API ===
  Future<bool> _submitReservation({
    required String roomNo,
    required String slot,
    required String user,
  }) async {
    // TODO: เปลี่ยนเป็น call API จริง
    // ตัวอย่างจำลอง: 80% สำเร็จ
    await Future.delayed(const Duration(milliseconds: 500));
    return Random().nextDouble() < 0.6;
  }

  // === 3) โชว์ผลลัพธ์ และปิดเองใน 3 วินาที ===
  Future<void> _showResultPopup({required bool ok}) async {
    final icon = ok ? Icons.check_circle_outline_rounded : Icons.cancel_rounded;
    final iconColor = ok ? const Color(0xFFBFFF7A) : const Color(0xFFE62727);
    final titleText = ok ? 'Request sent' : 'Request failed';
    final subtitleText = ok
        ? 'Your booking request has been\nsent for approval.'
        : 'Could not create your request.\nPlease try again later.';

    // นับถอยหลัง 3 วินาที
    final countdown = ValueNotifier<int>(5);
    Timer? timer;

    void startTimer() {
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        if (countdown.value <= 1) {
          t.cancel();
          // ปิด dialog เมื่อถึง 0
          Navigator.of(context, rootNavigator: true).maybePop();
        } else {
          countdown.value = countdown.value - 1;
        }
      });
    }

    startTimer();

    final dialogFuture = showAirDialog(
      context,
      height: 400,
      title: null,
      content: SizedBox(
        height: 290,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: iconColor),
            const SizedBox(height: 16),
            Text(
              titleText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitleText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      actions: [
        // ปุ่ม Close (3) ที่ตัวเลขอัปเดตตามเวลา
        ValueListenableBuilder<int>(
          valueListenable: countdown,
          builder: (_, secs, __) {
            return AppButton.solid(
              label: 'Close ($secs)',
              onPressed: () {
                timer?.cancel();
                Navigator.of(context, rootNavigator: true).maybePop();
              },
            );
          },
        ),
      ],
    );

    // รอจน dialog ปิด (กดเองหรือครบเวลา)
    await dialogFuture;

    // เคลียร์ทรัพยากร
    timer?.cancel();
    countdown.dispose();
  }

  // แถว label : value ใน popup
  Widget _popupRow({required String label, required String value}) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 18, height: 1.4, color: Colors.white),
        children: [
          TextSpan(
            text: '$label : ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:room_reservation_system_app/shared/widgets/widgets.dart';

Future<T?> showAirDialog<T>(
  BuildContext context, {
  String? title,
  String? message,
  Widget? content, // ถ้ามีจะใช้แทน message
  List<Widget>? actions, // ไม่ส่ง = มีปุ่ม Close ให้
  double width = 320,
  double? height, // null = สูงตามเนื้อหา
  double borderRadius = 24,
  bool dismissible = true,
  double backdropBlurSigma = 15, // blur ฉากหลังเป้าหมาย
  double barrierOpacity = 0.25,
  double maxHeightFactor = 0.70, // เพดาน 70% ของจอ
  Duration blurDuration = const Duration(milliseconds: 260),
  Duration panelDuration = const Duration(milliseconds: 200),
}) {
  final totalMs = blurDuration.inMilliseconds + panelDuration.inMilliseconds;
  final total = Duration(milliseconds: totalMs);

  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(barrierOpacity),
    transitionDuration: total,
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, __, ___) {
      // ขนาดจอ/เพดาน
      final size = MediaQuery.of(ctx).size;
      final maxW = size.width - 32;
      final maxH = size.height * maxHeightFactor;
      final dialogW = width.clamp(0, maxW).toDouble();
      final dialogH = height?.clamp(0, maxH).toDouble();

      // เฟส 1: blur ก่อน (0 → 1 ในครึ่งแรก)
      final blurPhase = CurvedAnimation(
        parent: anim,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      );
      final blurSigma = backdropBlurSigma * blurPhase.value;

      // เฟส 2: ค่อยเฟด+ซูม panel (ครึ่งหลัง)
      final panelPhase = CurvedAnimation(
        parent: anim,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
      );

      final body = _DialogBody(
        title: title,
        message: message,
        content: content,
        actions: actions,
      );

      final panel = FigmaPanel(
        width: dialogW,
        height: dialogH, // null = สูงตามเนื้อหา
        borderRadius: borderRadius,
        fills: const [
          FillLayer.gradient(
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x40FFFFFF), Color(0x10FFFFFF)],
            ),
          ),
        ],
        stroke: const StrokeSpec(
          weight: 1,
          position: StrokePosition.inside,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFF0F828C)],
          ),
        ),
        shadow: const ShadowSpec(
          color: Color(0xFF0F828C),
          offsetX: 0,
          offsetY: 4,
          blurSigma: 6,
          spread: 1,
        ),
        backgroundBlurSigma: 40, // เบลอ "ภายใน" แผง
        child: body,
      );

      return Stack(
        children: [
          // Backdrop blur (ต้องมี child—even empty—to trigger blur)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: const SizedBox.expand(),
            ),
          ),

          // Panel (บนสุด) — จำกัดเพดานและให้ขึ้นอย่างนุ่ม
          Center(
            child: Material(
              type: MaterialType.transparency,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
                child: FadeTransition(
                  opacity: panelPhase,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.96, end: 1.0).animate(panelPhase),
                    child: panel,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// layout ภายใน (title / content|message / actions)
class _DialogBody extends StatelessWidget {
  const _DialogBody({this.title, this.message, this.content, this.actions});

  final String? title;
  final String? message;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if ((title ?? '').trim().isNotEmpty) {
      children.add(const SizedBox(height: 14));
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (content != null) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.4,
            ),
            child: content!,
          ),
        ),
      );
    } else if ((message ?? '').trim().isNotEmpty) {
      children.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Text(
            message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    children.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: _buildActions(context),
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _buildActions(BuildContext context) {
    final acts =
        actions ??
        [
          AppButton.outline(
            label: 'Close',
            onPressed: () => Navigator.of(context).maybePop(),
            fullWidth: true,
          ),
        ];

    if (acts.length >= 2) {
      return Row(
        children: [
          Expanded(child: acts.first),
          const SizedBox(width: 12),
          Expanded(child: acts.last),
        ],
      );
    }
    return acts.first;
  }
}

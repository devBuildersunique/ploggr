import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});
  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _flash = false;
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      backgroundColor: const Color(0xFF102014),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => goBack(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Scan Litter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'About the sample camera',
                  onPressed: () => previewNotice(
                    context,
                    'Sample camera',
                    'This screen uses a bundled sample photo. No camera, gallery, flash, or AI detection is accessed. Tap the shutter to try reporting litter.',
                  ),
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/demo/litter.png',
                    fit: BoxFit.cover,
                    semanticLabel: 'Sample litter photo, not a live camera',
                  ),
                  ColoredBox(color: Colors.black.withValues(alpha: .07)),
                  const Positioned(
                    top: 18,
                    left: 12,
                    right: 12,
                    child: PreviewNote(
                      text: 'SAMPLE CAMERA · no camera access',
                      light: true,
                    ),
                  ),
                  Center(
                    child: FractionallySizedBox(
                      widthFactor: .77,
                      heightFactor: .46,
                      child: CustomPaint(painter: _ViewfinderPainter()),
                    ),
                  ),
                  Positioned(
                    bottom: 22,
                    left: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .68),
                        borderRadius: AppRadius.small,
                      ),
                      child: const Text(
                        'Take a photo of litter\n(e.g. plastic, paper, e-waste, etc.)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'Choose sample photo',
                    onPressed: () => openPage(context, AppRoutes.report),
                    icon: const LitterPhoto(height: 44, width: 44),
                  ),
                  Semantics(
                    label: 'Capture sample photo',
                    button: true,
                    child: InkWell(
                      onTap: () => openPage(context, AppRoutes.report),
                      borderRadius: AppRadius.pill,
                      child: Container(
                        width: 72,
                        height: 72,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: _flash
                        ? 'Turn sample flash off'
                        : 'Turn sample flash on',
                    onPressed: () {
                      setState(() => _flash = !_flash);
                      toast(
                        context,
                        'Sample flash ${_flash ? 'on' : 'off'} · device flash is not used',
                      );
                    },
                    icon: Icon(
                      _flash ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      color: _flash ? AppColors.gold : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final point in [
      Offset.zero,
      Offset(s.width, 0),
      Offset(0, s.height),
      Offset(s.width, s.height),
    ]) {
      c.save();
      c.translate(point.dx, point.dy);
      c.scale(point.dx == 0 ? 1 : -1, point.dy == 0 ? 1 : -1);
      c.drawPath(
        Path()
          ..moveTo(0, 31)
          ..lineTo(0, 12)
          ..quadraticBezierTo(0, 0, 12, 0)
          ..lineTo(31, 0),
        p,
      );
      c.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

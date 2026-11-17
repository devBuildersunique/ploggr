import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import 'ploggr_ui.dart';

class PloggrLogo extends StatelessWidget {
  const PloggrLogo({super.key, this.size = 58});
  final double size;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Ploggr',
    image: true,
    child: ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'pl',
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w700,
                letterSpacing: -3,
                height: 1.3,
                color: AppColors.forest,
              ),
            ),
            SizedBox(
              width: size * .57,
              height: size * .95,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: size * .09,
                    child: Container(
                      width: size * .52,
                      height: size * .53,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: size * .055,
                        ),
                      ),
                      child: Icon(
                        Icons.public_rounded,
                        color: AppColors.primary,
                        size: size * .39,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: -size * .02,
                    child: Transform.rotate(
                      angle: .25,
                      child: Icon(
                        Icons.eco,
                        color: AppColors.primary,
                        size: size * .34,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'ggr',
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w700,
                letterSpacing: -3,
                height: 1.3,
                color: AppColors.forest,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class LeafSprig extends StatelessWidget {
  const LeafSprig({super.key, this.width = 90, this.height = 120});
  final double width, height;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(size: Size(width, height), painter: _LeafPainter()),
  );
}

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 130);
    final stem = Path()
      ..moveTo(12, 128)
      ..quadraticBezierTo(52, 70, 53, 8);
    canvas.drawPath(
      stem,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.7,
    );
    for (final leaf in [
      (45.0, 13.0, -0.35, 1.0),
      (45.0, 42.0, 1.1, .9),
      (31.0, 67.0, -.7, .85),
      (30.0, 91.0, 1.0, .8),
    ]) {
      canvas.save();
      canvas.translate(leaf.$1, leaf.$2);
      canvas.rotate(leaf.$3);
      canvas.scale(leaf.$4);
      final shape = Path()
        ..moveTo(0, 0)
        ..cubicTo(-28, 16, -27, 42, 0, 60)
        ..cubicTo(23, 35, 22, 18, 0, 0);
      canvas.drawPath(
        shape,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFB7DE60), AppColors.primary],
          ).createShader(const Rect.fromLTWH(-25, 0, 50, 60)),
      );
      canvas.drawLine(
        const Offset(0, 5),
        const Offset(0, 56),
        Paint()
          ..color = Colors.white.withValues(alpha: .5)
          ..strokeWidth = .8,
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class LandscapeArt extends StatelessWidget {
  const LandscapeArt({
    super.key,
    this.child,
    this.height = 230,
    this.campus = false,
  });
  final Widget? child;
  final double height;
  final bool campus;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    child: CustomPaint(
      painter: _LandscapePainter(campus),
      child: SizedBox.expand(child: child),
    ),
  );
}

class _LandscapePainter extends CustomPainter {
  const _LandscapePainter(this.campus);
  final bool campus;
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.background);
    if (campus) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = const Color(0xFFD8EFF5),
      );
    }
    for (var layer = 0; layer < 3; layer++) {
      final top = h * (.45 + layer * .15);
      final p = Path()
        ..moveTo(0, top)
        ..cubicTo(
          w * .25,
          top - h * .25,
          w * .55,
          top + h * .25,
          w,
          top - h * .07,
        )
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close();
      canvas.drawPath(
        p,
        Paint()
          ..color = (campus
              ? [
                  const Color(0xFFE5F2D9),
                  const Color(0xFFC6E7A0),
                  const Color(0xFF93CC62),
                ]
              : [
                  const Color(0xFFEEF7E7),
                  const Color(0xFFE5F2D9),
                  const Color(0xFFD3E9BF),
                ])[layer],
      );
    }
    for (final x in [.04, .16, .86, .96]) {
      final trunk = Paint()
        ..color = const Color(0xFF5B833F)
        ..strokeWidth = 2.5;
      final y = h * (x < .5 ? .58 : .62);
      canvas.drawLine(Offset(w * x, y), Offset(w * x, y + h * .21), trunk);
      for (var i = 0; i < 3; i++) {
        canvas.drawCircle(
          Offset(w * x + (i - 1) * 9, y + (i == 1 ? -10 : 0)),
          h * .095,
          Paint()
            ..color = x < .5
                ? const Color(0xFF7DBD45)
                : const Color(0xFFABD77C),
        );
      }
    }
    if (campus) {
      final rect = Rect.fromLTWH(w * .32, h * .3, w * .4, h * .4);
      canvas.drawRect(rect, Paint()..color = const Color(0xFFF1C898));
      final roof = Path()
        ..moveTo(w * .28, h * .32)
        ..lineTo(w * .52, h * .1)
        ..lineTo(w * .76, h * .32)
        ..close();
      canvas.drawPath(roof, Paint()..color = const Color(0xFFDC986C));
      for (var i = 0; i < 6; i++) {
        canvas.drawRect(
          Rect.fromLTWH(w * (.35 + i * .06), h * .38, w * .025, h * .29),
          Paint()..color = const Color(0xFFFAEDCD),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LandscapePainter oldDelegate) =>
      campus != oldDelegate.campus;
}

class TrophyArt extends StatelessWidget {
  const TrophyArt({super.key});
  @override
  Widget build(BuildContext context) => LandscapeArt(
    height: 300,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 205,
          height: 205,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE1F3C4), Color(0xFFBADD8E)],
            ),
          ),
        ),
        Icon(Icons.emoji_events_rounded, size: 168, color: AppColors.primary),
        const Positioned(
          top: 112,
          child: Icon(Icons.star_rounded, color: Colors.white, size: 45),
        ),
        const Positioned(
          left: 24,
          bottom: 12,
          child: LeafSprig(width: 55, height: 100),
        ),
        const Positioned(
          right: 20,
          bottom: 26,
          child: LeafSprig(width: 45, height: 86),
        ),
        const Positioned(
          left: 35,
          top: 68,
          child: Icon(Icons.auto_awesome, color: AppColors.leaf, size: 24),
        ),
        const Positioned(
          right: 40,
          top: 58,
          child: Icon(Icons.auto_awesome, color: AppColors.leaf, size: 18),
        ),
      ],
    ),
  );
}

class BadgeArt extends StatelessWidget {
  const BadgeArt({
    super.key,
    this.size = 72,
    this.locked = false,
    this.icon = Icons.eco_rounded,
    this.gold = false,
  });
  final double size;
  final bool locked, gold;
  final IconData icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size * 1.08,
    child: CustomPaint(
      painter: _ShieldPainter(locked: locked, gold: gold),
      child: Center(
        child: Padding(
          padding: EdgeInsets.only(bottom: size * .12),
          child: Icon(
            icon,
            size: size * .47,
            color: locked
                ? Colors.white
                : gold
                ? AppColors.primary
                : Colors.white,
          ),
        ),
      ),
    ),
  );
}

class _ShieldPainter extends CustomPainter {
  const _ShieldPainter({required this.locked, required this.gold});
  final bool locked, gold;
  @override
  void paint(Canvas c, Size s) {
    c.save();
    c.scale(s.width / 100, s.height / 108);
    final ribbon = Path()
      ..moveTo(22, 67)
      ..lineTo(6, 99)
      ..lineTo(28, 94)
      ..lineTo(41, 107)
      ..lineTo(51, 75)
      ..lineTo(72, 108)
      ..lineTo(80, 93)
      ..lineTo(96, 98)
      ..lineTo(78, 64)
      ..close();
    c.drawPath(
      ribbon,
      Paint()..color = locked ? const Color(0xFFBCC3B8) : AppColors.primary,
    );
    final path = Path()
      ..moveTo(50, 1)
      ..quadraticBezierTo(30, 11, 11, 13)
      ..lineTo(13, 53)
      ..quadraticBezierTo(15, 77, 50, 94)
      ..quadraticBezierTo(85, 77, 87, 53)
      ..lineTo(89, 13)
      ..quadraticBezierTo(68, 11, 50, 1)
      ..close();
    c.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: locked
              ? [const Color(0xFFAAB2A7), const Color(0xFF7D8879)]
              : gold
              ? [const Color(0xFFFFE876), AppColors.gold]
              : [const Color(0xFF9BD64A), AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(const Rect.fromLTWH(10, 0, 80, 94)),
    );
    c.save();
    c.translate(50, 44);
    c.scale(.78);
    c.translate(-50, -44);
    c.drawPath(
      path,
      Paint()
        ..color = gold
            ? const Color(0xFFFFF6BB)
            : Colors.white.withValues(alpha: .17),
    );
    c.restore();
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _ShieldPainter oldDelegate) =>
      oldDelegate.locked != locked || oldDelegate.gold != gold;
}

class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, this.index = 0, this.radius = 21});
  final int index;
  final double radius;
  @override
  Widget build(BuildContext context) => CircleAvatar(
    radius: radius,
    backgroundColor: [
      const Color(0xFFF5DCD1),
      const Color(0xFFDDE9B8),
      const Color(0xFFD5E9EE),
      const Color(0xFFF7E5C0),
    ][index % 4],
    child: ClipOval(
      child: CustomPaint(
        size: Size.square(radius * 2),
        painter: _PersonPainter(index),
      ),
    ),
  );
}

class _PersonPainter extends CustomPainter {
  const _PersonPainter(this.index);
  final int index;
  @override
  void paint(Canvas c, Size s) {
    c.save();
    c.scale(s.width / 50);
    c.drawOval(
      const Rect.fromLTWH(7, 32, 36, 32),
      Paint()
        ..color = [
          AppColors.primary,
          AppColors.forest,
          const Color(0xFF3E6A8B),
          const Color(0xFFCE9D2C),
        ][index % 4],
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(13, 6, 24, index.isOdd ? 35 : 25),
        const Radius.circular(13),
      ),
      Paint()..color = const Color(0xFF29291F),
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(21, 28, 8, 10),
        const Radius.circular(3),
      ),
      Paint()..color = const Color(0xFFB57B50),
    );
    c.drawOval(
      const Rect.fromLTWH(15, 11, 20, 22),
      Paint()..color = const Color(0xFFD59B6B),
    );
    final hair = Path()
      ..moveTo(13, 16)
      ..quadraticBezierTo(10, 0, 29, 7)
      ..quadraticBezierTo(39, 7, 35, 20)
      ..lineTo(30, 12)
      ..quadraticBezierTo(22, 18, 13, 16);
    c.drawPath(hair, Paint()..color = const Color(0xFF29291F));
    for (final x in [20.0, 29.0]) {
      c.drawCircle(Offset(x, 21), 1, Paint()..color = AppColors.ink);
    }
    c.drawArc(
      const Rect.fromLTWH(21, 23, 8, 5),
      0,
      math.pi,
      false,
      Paint()
        ..color = const Color(0xFF77422E)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke,
    );
    c.restore();
  }

  @override
  bool shouldRepaint(covariant _PersonPainter oldDelegate) =>
      oldDelegate.index != index;
}

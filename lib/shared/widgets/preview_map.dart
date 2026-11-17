import 'package:material_ui/material_ui.dart';
import 'ploggr_ui.dart';

/// An offline illustration, intentionally not a real geographic map.
class PreviewMap extends StatelessWidget {
  const PreviewMap({
    super.key,
    this.route = false,
    this.cleanups = false,
    this.onMarkerTap,
    this.selected = 0,
    this.controller,
  });
  final bool route, cleanups;
  final int selected;
  final ValueChanged<int>? onMarkerTap;
  final TransformationController? controller;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadius.card,
    child: LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: controller,
              minScale: 1,
              maxScale: 2.5,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _StreetMapPainter(route)),
                    ),
                    for (var i = 0; i < 5; i++)
                      Positioned(
                        left:
                            constraints.maxWidth *
                                [.25, .72, .12, .76, .44][i] -
                            24,
                        top:
                            constraints.maxHeight *
                                [.16, .12, .40, .57, .73][i] -
                            24,
                        child: Semantics(
                          label: cleanups
                              ? 'Clean-up ${i + 1}'
                              : 'Litter spot ${i + 1}',
                          selected: selected == i,
                          button: true,
                          child: IconButton(
                            tooltip: cleanups
                                ? 'View clean-up ${i + 1}'
                                : 'View litter spot ${i + 1}',
                            onPressed: () => onMarkerTap?.call(i),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              minimumSize: const Size(48, 48),
                              shadowColor: Colors.black26,
                              padding: EdgeInsets.zero,
                            ),
                            icon: SizedBox(
                              width: 48,
                              height: 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: selected == i ? 47 : 43,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0x22000000),
                                        blurRadius: 5,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: selected == i ? 41 : 37,
                                    color: cleanups || i.isEven
                                        ? AppColors.primary
                                        : AppColors.coral,
                                  ),
                                  if (!cleanups && i.isOdd)
                                    Positioned(
                                      top: 12,
                                      child: Icon(
                                        Icons.shopping_bag_rounded,
                                        color: Colors.white,
                                        size: selected == i ? 15 : 13,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    Align(
                      alignment: const Alignment(.05, .12),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.blue.withValues(alpha: .2),
                        ),
                        child: Center(
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.blue,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .94),
                borderRadius: AppRadius.pill,
              ),
              child: const Text(
                'Illustrative map',
                style: TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _StreetMapPainter extends CustomPainter {
  const _StreetMapPainter(this.route);
  final bool route;
  @override
  void paint(Canvas c, Size s) {
    c.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFF2F0E1));
    c.save();
    c.translate(s.width * .5, s.height * .5);
    c.rotate(.43);
    final extent = s.longestSide * 1.7;
    for (var x = -extent; x < extent; x += 32) {
      for (var y = -extent; y < extent; y += 43) {
        final green = ((x / 32).round() + (y / 43).round()) % 6 == 0;
        c.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x + 3, y + 3, 26, 37),
            const Radius.circular(3),
          ),
          Paint()
            ..color = green ? const Color(0xFFD8EAC4) : const Color(0xFFE9E5D3),
        );
      }
    }
    for (var x = -extent; x < extent; x += 32) {
      c.drawLine(
        Offset(x, -extent),
        Offset(x, extent),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3,
      );
    }
    for (var y = -extent; y < extent; y += 43) {
      c.drawLine(
        Offset(-extent, y),
        Offset(extent, y),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 3,
      );
    }
    final road = Path()
      ..moveTo(-extent, 100)
      ..cubicTo(-100, 100, -50, -100, extent, -130);
    c.drawPath(
      road,
      Paint()
        ..color = const Color(0xFFDFD4A4)
        ..strokeWidth = 15
        ..style = PaintingStyle.stroke,
    );
    c.drawPath(
      road,
      Paint()
        ..color = const Color(0xFFFFFCED)
        ..strokeWidth = 11
        ..style = PaintingStyle.stroke,
    );
    final river = Path()
      ..moveTo(-s.width * .4, -extent)
      ..cubicTo(-s.width * .7, -60, s.width * .5, 90, -s.width * .15, extent);
    c.drawPath(
      river,
      Paint()
        ..color = const Color(0xFFCDE7DB)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke,
    );
    c.restore();
    if (route) {
      final p = Path()
        ..moveTo(s.width * .19, s.height * .75)
        ..lineTo(s.width * .30, s.height * .61)
        ..lineTo(s.width * .41, s.height * .56)
        ..lineTo(s.width * .52, s.height * .6)
        ..lineTo(s.width * .62, s.height * .48)
        ..lineTo(s.width * .67, s.height * .32)
        ..lineTo(s.width * .76, s.height * .23);
      c.drawPath(
        p,
        Paint()
          ..color = Colors.white
          ..strokeWidth = 7
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round,
      );
      c.drawPath(
        p,
        Paint()
          ..color = AppColors.blue
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke
          ..strokeJoin = StrokeJoin.round,
      );
      c.drawCircle(
        Offset(s.width * .19, s.height * .75),
        9,
        Paint()..color = Colors.white,
      );
      c.drawCircle(
        Offset(s.width * .19, s.height * .75),
        6,
        Paint()..color = AppColors.primary,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StreetMapPainter oldDelegate) =>
      route != oldDelegate.route;
}

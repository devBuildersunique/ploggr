import 'dart:math' as math;
import 'package:flutter/material.dart';



// class EndSessionApp extends StatelessWidget {
//   const EndSessionApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'End Session Summary',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(fontFamily: 'Roboto', useMaterial3: true),
//       home: const EndSessionPage(),
//     );
//   }
// }

// ---- Palette ---------------------------------------------------------------
const kOrange = Color(0xFFF7941D);
const kLime = Color(0xFFD8D93A);
const kDeepBrown = Color(0xFF6B3A0E);
const kCardGrey = Color(0xFFF1EEEC);
const kTextGrey = Color(0xFF8A8A8A);
const kWarnBg = Color(0xFFFBE4E1);
const kWarnText = Color(0xFFC0392B);

/// This page owns mutable session data (photo captured, item counts, points),
/// so it's a StatefulWidget rather than stateless — the confirm flow and the
/// "snap your haul" step both change what's on screen at runtime.
class EndSessionPage extends StatefulWidget {
  const EndSessionPage({super.key});

  @override
  State<EndSessionPage> createState() => _EndSessionPageState();
}

class _EndSessionPageState extends State<EndSessionPage> {
  bool _photoTaken = false;
  bool _isSubmitting = false;

  // Mock haul-detection data — replace with real detection results.
  final int itemsDetected = 9;
  final int itemsTapped = 7;
  final String typesFound = 'bottles, can, wrapper';
  final int estWeightGrams = 340;
  final int countDifference = 2;
  final int creditedItems = 8;

  final int effortPts = 248;
  final int collectPts = 86;
  final double multiplier = 1.3;
  final int totalPtsEarned = 433;
  final double kgTowardGoal = 0.34;

  void _handleSnapPhoto() {
    // Hook up image_picker / camera here.
    setState(() => _photoTaken = true);
  }

  Future<void> _handleConfirm() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600)); // mock submit
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 141, 107, 90),
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content, padded at the bottom so the floating
            // confirm button never covers the last card.
            Column(
              children: [
                const _TopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        const Text(
                          'Snap your haul',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'One photo of everything in your bag',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 20),
                        _PhotoDropZone(
                          photoTaken: _photoTaken,
                          onTap: _handleSnapPhoto,
                        ),
                        const SizedBox(height: 20),
                        _DetectionSummaryCard(
                          itemsDetected: itemsDetected,
                          itemsTapped: itemsTapped,
                          typesFound: typesFound,
                          estWeightGrams: estWeightGrams,
                          countDifference: countDifference,
                          creditedItems: creditedItems,
                        ),
                        const SizedBox(height: 16),
                        _PointsRow(
                          effortPts: effortPts,
                          collectPts: collectPts,
                          multiplier: multiplier,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Floating confirm button, pinned above the bottom edge.
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _ConfirmButton(
                totalPtsEarned: totalPtsEarned,
                kgTowardGoal: kgTowardGoal,
                isSubmitting: _isSubmitting,
                onPressed: _handleConfirm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Top bar ----------------------------------------------------------------
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Text(
            'Verify haul',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Photo drop zone ---------------------------------------------------------
class _PhotoDropZone extends StatelessWidget {
  final bool photoTaken;
  final VoidCallback onTap;

  const _PhotoDropZone({required this.photoTaken, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          // Angular orange/lime background like the mockup.
          Positioned.fill(
            child: CustomPaint(painter: _DiagonalBackgroundPainter()),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: DottedBorderBox(
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: kOrange,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        photoTaken
                            ? Icons.check_rounded
                            : Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      photoTaken ? 'Photo captured' : 'Dump bag, take photo',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Or upload from gallery',
                      style: TextStyle(fontSize: 12, color: kTextGrey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple diagonal orange/lime shapes to echo the reference background.
class _DiagonalBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final orangePaint = Paint()..color = kOrange;
    final limePaint = Paint()..color = kLime;

    final orangePath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.55, 0)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(orangePath, orangePaint);

    final limePath = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.6)
      ..lineTo(size.width * 0.4, 0)
      ..close();
    canvas.drawPath(limePath, limePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dashed-border tappable container (Flutter has no built-in dashed border).
class DottedBorderBox extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const DottedBorderBox({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: kOrange, radius: 14),
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    const dashWidth = 6.0;
    const dashSpace = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---- Detection summary card --------------------------------------------------
class _DetectionSummaryCard extends StatelessWidget {
  final int itemsDetected;
  final int itemsTapped;
  final String typesFound;
  final int estWeightGrams;
  final int countDifference;
  final int creditedItems;

  const _DetectionSummaryCard({
    required this.itemsDetected,
    required this.itemsTapped,
    required this.typesFound,
    required this.estWeightGrams,
    required this.countDifference,
    required this.creditedItems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardGrey,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow(label: 'Items detected', value: '$itemsDetected'),
          const Divider(height: 22),
          _SummaryRow(label: 'You tapped', value: '$itemsTapped'),
          const Divider(height: 22),
          _SummaryRow(
            label: 'Types found',
            value: typesFound,
            valueColor: kDeepBrown,
            valueWeight: FontWeight.w700,
          ),
          const Divider(height: 22),
          _SummaryRow(label: 'Est. weight', value: '~$estWeightGrams g'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: kWarnBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error, color: kWarnText, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: kWarnText,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text:
                              'Count differs by $countDifference — credited $creditedItems items (midpoint). ',
                        ),
                        const TextSpan(
                          text: 'Tap to flag.',
                          style: TextStyle(decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight? valueWeight;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13.5, color: kTextGrey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: valueWeight ?? FontWeight.w700,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

// ---- Points row ---------------------------------------------------------------
class _PointsRow extends StatelessWidget {
  final int effortPts;
  final int collectPts;
  final double multiplier;

  const _PointsRow({
    required this.effortPts,
    required this.collectPts,
    required this.multiplier,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PointsChip(
            value: '$effortPts',
            label: 'Effort pts',
            bg: kCardGrey,
            valueColor: Colors.black87,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PointsChip(
            value: '$collectPts',
            label: 'Collect pts',
            bg: kCardGrey,
            valueColor: Colors.black87,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PointsChip(
            value: '${multiplier}x',
            label: 'Multiplier',
            bg: Colors.white,
            valueColor: kOrange,
            border: kOrange,
          ),
        ),
      ],
    );
  }
}

class _PointsChip extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color valueColor;
  final Color? border;

  const _PointsChip({
    required this.value,
    required this.label,
    required this.bg,
    required this.valueColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 11.5, color: kTextGrey)),
        ],
      ),
    );
  }
}

// ---- Floating confirm button -----------------------------------------------
class _ConfirmButton extends StatelessWidget {
  final int totalPtsEarned;
  final double kgTowardGoal;
  final bool isSubmitting;
  final VoidCallback onPressed;

  const _ConfirmButton({
    required this.totalPtsEarned,
    required this.kgTowardGoal,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: isSubmitting ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: kOrange,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kOrange.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isSubmitting
              ? const SizedBox(
                  height: 22,
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Text(
                      'Confirm · $totalPtsEarned pts earned',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+${kgTowardGoal.toStringAsFixed(2)} kg toward Block guardian',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
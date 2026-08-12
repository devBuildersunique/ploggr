import 'package:flutter/material.dart';
import 'package:ploggr/features/home/end_session.dart' as temp;

class EndSessionPage extends StatelessWidget {
  const EndSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF9200),
      // appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFFFCF8F9),
            child: Column(
              children: [
                // ---------------- HEADER ----------------
                Container(
                  height: 79,
                  width: double.infinity,
                  color: const Color(0xFFFF9200),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '♻',
                            style: TextStyle(
                              fontSize: 27,
                              color: Color(0xFF00A878),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      const Text(
                        'Plogging',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // ---------------- MAP ----------------
                SizedBox(
                  height: 299,
                  width: double.infinity,
                  child: CustomPaint(painter: FakeMapPainter()),
                ),

                // ---------------- CONTENT ----------------
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 27),
                    child: Column(
                      children: [
                        const SizedBox(height: 27),

                        // Statistics
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            StatCard(value: '3.2', label: 'km'),
                            StatCard(value: '24:10', label: 'time'),
                            StatCard(
                              value: '7',
                              label: 'Steps',
                              valueColor: Color(0xFFA45A00),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Camera
                        Container(
                          width: 112,
                          height: 112,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Temporary photo background
                                Image.network(
                                  'https://images.unsplash.com/photo-1500534623283-312aade485b7',
                                  width: 112,
                                  height: 112,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      color: Colors.grey.shade300,
                                    );
                                  },
                                ),

                                // Green camera circle
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF12B88A),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 39,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 19),

                        // Waste chips
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            WasteChip(text: '3 bottles'),
                            WasteChip(text: '2 wrappers'),
                            WasteChip(text: '1 can'),
                            WasteChip(text: '1 bag'),
                          ],
                        ),

                        const Spacer(),

                        // End session button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => temp.EndSessionPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFA65C00),
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.stop_circle_outlined, size: 25),
                                SizedBox(width: 10),
                                Text(
                                  'End session',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 39),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.valueColor = const Color(0xFF292929),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: TextStyle(fontSize: 16, color: valueColor)),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF555555)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WASTE CHIP
// ============================================================

class WasteChip extends StatelessWidget {
  final String text;

  const WasteChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8E1E1)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF333333)),
      ),
    );
  }
}

// ============================================================
// TEMPORARY MAP
// ============================================================

class FakeMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Background
    final backgroundPaint = Paint()..color = const Color(0xFF061C12);

    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // Grid / roads
    final roadPaint = Paint()
      ..color = const Color(0xFF0D3022)
      ..strokeWidth = 1;

    // Vertical roads
    for (double x = 0; x < size.width; x += 51) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }

    // Horizontal roads
    for (double y = 0; y < size.height; y += 51) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }

    // Route
    final routePaint = Paint()
      ..color = const Color(0xFF16B88A)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final route = Path();

    route.moveTo(0, size.height * .70);

    route.cubicTo(
      size.width * .20,
      size.height * .54,
      size.width * .42,
      size.height * .40,
      size.width * .62,
      size.height * .46,
    );

    route.cubicTo(
      size.width * .78,
      size.height * .51,
      size.width * .87,
      size.height * .40,
      size.width,
      size.height * .28,
    );

    canvas.drawPath(route, routePaint);

    // Route markers
    final markerPaint = Paint()..color = const Color(0x996F4A16);

    canvas.drawCircle(
      Offset(size.width * .44, size.height * .58),
      26,
      markerPaint,
    );

    canvas.drawCircle(
      Offset(size.width * .79, size.height * .42),
      18,
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

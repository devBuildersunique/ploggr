import 'package:flutter/material.dart';


// ---- Palette -------------------------------------------------------------
const kOrange = Color(0xFFF7941D);
const kDeepBrown = Color(0xFF6B3A0E);
const kCardBg = Colors.white;
const kPageBg = Color(0xFFFBF3EF);
const kTextGrey = Color(0xFF8A8A8A);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPageBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _HeaderSection(),
                    Transform.translate(
                      offset: const Offset(0, -30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _TotalImpactCard(),
                            const SizedBox(height: 16),
                            const _StatsGrid(),
                            const SizedBox(height: 16),
                            const _StreakCard(),
                            const SizedBox(height: 24),
                            const _StartPloggingButton(),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const _BottomNavBar(),
          ],
        ),
      ),
    );
  }
}

// ---- Header ---------------------------------------------------------------
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        color: kOrange,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.menu, color: Colors.white, size: 28),
                const Text(
                  'Plogging',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/100?img=47',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              'Good Morning, Alex!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Ready to make an impact today?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Curved bottom edge for the header (like the mockup's diagonal cut).
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ---- Total Impact card -----------------------------------------------------
class _TotalImpactCard extends StatelessWidget {
  const _TotalImpactCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Impact',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: kOrange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      'Top 10%',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '4.2',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: kOrange,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  'kg',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.35,
              minHeight: 4,
              backgroundColor: const Color(0xFFF0E4DC),
              valueColor: const AlwaysStoppedAnimation<Color>(kDeepBrown),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0ED),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: kOrange.withOpacity(0.15),
                  child: const Icon(
                    Icons.local_drink_outlined,
                    color: kOrange,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                    children: [
                      TextSpan(text: 'Equivalent to saving\n'),
                      TextSpan(
                        text: '210 ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: kDeepBrown,
                        ),
                      ),
                      TextSpan(text: 'plastic bottles'),
                    ],
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

// ---- Stats grid -------------------------------------------------------------
class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Expanded(
              child: _StatCard(
                icon: Icons.directions_run,
                iconColor: kDeepBrown,
                value: '12',
                label: 'Sessions',
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                icon: Icons.route_outlined,
                iconColor: Color(0xFF6B8E23),
                value: '48.5',
                label: 'km run',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: const [
            Expanded(
              child: _StatCard(
                icon: Icons.emoji_events_outlined,
                iconColor: Color(0xFFD9A441),
                value: '#42',
                label: 'Adyar Rank',
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: _StatCard(
                icon: Icons.park_outlined,
                iconColor: kDeepBrown,
                value: 'Lvl 3',
                label: 'Trail Keeper',
                highlighted: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final bool highlighted;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFCEFDD) : kCardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: kTextGrey),
          ),
        ],
      ),
    );
  }
}

// ---- Streak card -------------------------------------------------------------
class _StreakCard extends StatelessWidget {
  const _StreakCard();

  static const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  // 0 = not started, 1 = done, 2 = today/in progress
  static const status = [1, 1, 1, 2, 0, 0, 0];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🔥', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    '5 Day Streak!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const Text(
                'View History',
                style: TextStyle(
                  color: kOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (i) {
              final isToday = status[i] == 2;
              final isDone = status[i] == 1;
              return Column(
                children: [
                  Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isToday ? kDeepBrown : kTextGrey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? kOrange
                          : (isToday ? Colors.white : const Color(0xFFF0EBE8)),
                      border: isToday
                          ? Border.all(color: kDeepBrown, width: 1.5)
                          : null,
                    ),
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : isToday
                            ? const Icon(
                                Icons.directions_run,
                                color: kDeepBrown,
                                size: 18,
                              )
                            : const Text(
                                '-',
                                style: TextStyle(
                                  color: kTextGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ---- Start Plogging button ----------------------------------------------
class _StartPloggingButton extends StatelessWidget {
  const _StartPloggingButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: kDeepBrown,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_arrow, size: 22),
            SizedBox(width: 8),
            Text(
              'Start Plogging',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- Bottom nav bar -----------------------------------------------------
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _NavItem(icon: Icons.home_rounded, label: 'Home', selected: true),
              _NavItem(icon: Icons.eco_outlined, label: 'Impact'),
              _NavItem(icon: Icons.bar_chart_rounded, label: 'Rank'),
              _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? kOrange : kTextGrey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selected)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: kOrange,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          )
        else
          Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
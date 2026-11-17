import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:ploggr/core/constants/app_colors.dart';
import 'package:ploggr/routes/app_routes.dart';

// import 'package:ploggr/features/track/track_page.dart';
// import 'package:ploggr/features/profile/profile_page.dart';

// ---- Palette -------------------------------------------------------------
class BottomNavBar extends StatelessWidget {
  final String caller;
  const BottomNavBar({super.key, this.caller = "home"});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: caller == 'home',
                onTap: () {
                  context.go(AppRoutes.home);
                },
              ),
              _NavItem(
                icon: Icons.eco_outlined,
                label: 'Impact',
                onTap: () {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const TrackPage()),
                  // );
                },
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Ranks',
                selected: caller == 'ranks',
                onTap: () {
                  context.go(AppRoutes.leaderboard);
                },
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                onTap: () {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const ProfilePage()),
                  // );
                },
              ),
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
  final VoidCallback? onTap; // 1. Add the callback parameter

  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
    this.onTap, // 2. Initialize it in the constructor
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.orange : AppColors.textGrey;

    // 3. Wrap the column in a GestureDetector
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior
          .opaque, // Ensures the whole area is clickable, not just the visible pixels
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selected)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.orange,
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
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';
import '../../routes/app_routes.dart';
import 'ploggr_ui.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key, this.caller = 'home'});
  final String caller;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.surface,
      border: Border(top: BorderSide(color: AppColors.border)),
    ),
    child: SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _item(
                  context,
                  'home',
                  'Home',
                  Icons.home_outlined,
                  Icons.home_rounded,
                  AppRoutes.home,
                ),
                _item(
                  context,
                  'explore',
                  'Explore',
                  Icons.search_rounded,
                  Icons.search_rounded,
                  AppRoutes.map,
                ),
                Expanded(
                  child: Center(
                    heightFactor: 1,
                    child: IconButton.filled(
                      tooltip: 'Create a litter report',
                      onPressed: () => openPage(context, AppRoutes.scan),
                      icon: const Icon(Icons.add_rounded, size: 28),
                    ),
                  ),
                ),
                _item(
                  context,
                  'community',
                  'Community',
                  Icons.diversity_3_outlined,
                  Icons.diversity_3_rounded,
                  AppRoutes.community,
                ),
                _item(
                  context,
                  'profile',
                  'Profile',
                  Icons.person_outline_rounded,
                  Icons.person_rounded,
                  AppRoutes.profile,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  Widget _item(
    BuildContext context,
    String id,
    String label,
    IconData icon,
    IconData active,
    String route,
  ) {
    final selected = caller == id;
    final color = selected ? AppColors.primary : AppColors.muted;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        child: InkWell(
          borderRadius: AppRadius.small,
          onTap: () => switchPage(context, route),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(selected ? active : icon, color: color, size: 23),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.1,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

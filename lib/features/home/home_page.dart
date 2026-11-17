import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../../shared/widgets/eco_art.dart';
import '../../shared/widgets/bottom_navigation.dart';
import '../plogging/application/session_controller.dart';
import '../profile/profile_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final impact = ref.watch(impactProvider);
    final session = ref.watch(sessionProvider);
    final name = ref.watch(profileProvider).split(' ').first;
    return Scaffold(
      bottomNavigationBar: const BottomNavBar(),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Hi, $name! 👋',
                        style: AppText.title.copyWith(fontSize: 23),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Notifications',
                      onPressed: () => previewNotice(
                        context,
                        'A little green inspiration',
                        'Your next clean-up is waiting! Explore nearby events and join a sample community drive. Notifications are a preview.',
                      ),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                EcoCard(
                  color: AppColors.paleGreen,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 17,
                  ),
                  child: Row(
                    children: [
                      const LeafSprig(width: 73, height: 98),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your Impact', style: AppText.label),
                            const SizedBox(height: 3),
                            Text(
                              '${impact.kg.toStringAsFixed(1)} kg',
                              style: AppText.hero,
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'of litter collected',
                              style: AppText.body,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: StatTile(
                        value: '${impact.sessions}',
                        label: 'Sessions',
                        icon: Icons.route_rounded,
                        onTap: () => openPage(context, AppRoutes.activity),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: StatTile(
                        value: '3',
                        label: 'Challenges',
                        icon: Icons.emoji_events_outlined,
                        onTap: () => openPage(context, AppRoutes.challenges),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: StatTile(
                        value: '5',
                        label: 'Badges',
                        icon: Icons.workspace_premium_rounded,
                        color: AppColors.gold,
                        onTap: () => openPage(context, AppRoutes.badges),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                PrimaryButton(
                  session.active ? 'Resume Plog Session' : 'Start Plog Session',
                  icon: Icons.directions_run_rounded,
                  onPressed: () {
                    if (!session.active) {
                      ref.read(sessionProvider.notifier).start();
                    }
                    openPage(context, AppRoutes.session);
                  },
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  'Scan Litter',
                  icon: Icons.qr_code_scanner_rounded,
                  onPressed: () => openPage(context, AppRoutes.scan),
                ),
                const SectionTitle('Ongoing Challenge'),
                EcoCard(
                  onTap: () => openPage(context, AppRoutes.challenges),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(
                          color: AppColors.paleGreen,
                          borderRadius: AppRadius.small,
                        ),
                        child: const Icon(
                          Icons.directions_run_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Campus Clean-up', style: AppText.label),
                            const SizedBox(height: 3),
                            const Text(
                              'Collect 20 kg by Nov 22',
                              style: AppText.caption,
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: AppRadius.pill,
                              child: LinearProgressIndicator(
                                value: (impact.kg / 20).clamp(0, 1),
                                minHeight: 6,
                                backgroundColor: AppColors.paleGreen,
                                color: AppColors.leaf,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${impact.kg.toStringAsFixed(1)} / 20 kg',
                              style: AppText.caption.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
                ),
                const SectionTitle('Quick Actions'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _quick(
                      context,
                      'Nearby\nClean-ups',
                      Icons.location_on_outlined,
                      AppRoutes.cleanups,
                    ),
                    const SizedBox(width: 7),
                    _quick(
                      context,
                      'Litter\nMap',
                      Icons.map_outlined,
                      AppRoutes.map,
                    ),
                    const SizedBox(width: 7),
                    _quick(
                      context,
                      'Leaderboard',
                      Icons.emoji_events_outlined,
                      AppRoutes.leaderboard,
                    ),
                    const SizedBox(width: 7),
                    _quick(
                      context,
                      'My\nImpact',
                      Icons.insights_rounded,
                      AppRoutes.profile,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const PreviewNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quick(
    BuildContext context,
    String label,
    IconData icon,
    String route,
  ) => Expanded(
    child: EcoCard(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 12),
      onTap: () => openPage(context, route),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 23),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              height: 1.3,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

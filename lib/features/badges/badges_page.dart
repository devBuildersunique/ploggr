import 'package:material_ui/material_ui.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../../shared/widgets/eco_art.dart';

class BadgesPage extends StatelessWidget {
  const BadgesPage({super.key});
  static const _badges = [
    (
      'First Plog',
      Icons.check_rounded,
      false,
      'Finish your first plogging session.',
    ),
    ('5 kg\nCollector', Icons.eco_rounded, false, 'Collect 5 kg of litter.'),
    (
      'Event\nParticipant',
      Icons.park_rounded,
      false,
      'Take part in a community clean-up.',
    ),
    (
      'Eco\nRunner',
      Icons.directions_run_rounded,
      false,
      'Complete five plogging sessions.',
    ),
    (
      'Community\nHero',
      Icons.star_rounded,
      false,
      'Help your community care for shared spaces.',
    ),
    (
      '25 kg\nCollector',
      Icons.lock_rounded,
      true,
      'Collect 25 kg of litter to unlock this badge.',
    ),
  ];
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'My Badges',
    child: Column(
      children: [
        const LandscapeArt(
          height: 150,
          child: Center(child: BadgeArt(size: 126, gold: true)),
        ),
        const SizedBox(height: 12),
        const Text('5 Badges Earned', style: AppText.title),
        const SizedBox(height: 6),
        const Text('Keep plogging to unlock more!'),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 10,
            runSpacing: 12,
            children: _badges
                .map(
                  (badge) => SizedBox(
                    width: (constraints.maxWidth - 20) / 3,
                    child: EcoCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 16,
                      ),
                      onTap: () => previewNotice(
                        context,
                        badge.$1.replaceAll('\n', ' '),
                        '${badge.$4}\n\n${badge.$3 ? 'Locked in this preview.' : 'Earned in the sample profile.'}',
                      ),
                      child: Column(
                        children: [
                          BadgeArt(size: 47, icon: badge.$2, locked: badge.$3),
                          const SizedBox(height: 10),
                          Text(
                            badge.$1,
                            textAlign: TextAlign.center,
                            style: AppText.label.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 24),
        const PreviewNote(
          text: 'Preview achievements · 5 earned, 1 to grow toward',
        ),
      ],
    ),
  );
}

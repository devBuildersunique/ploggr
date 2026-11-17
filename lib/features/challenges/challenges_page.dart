import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/preview/preview_data.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../../shared/widgets/eco_art.dart';
import '../plogging/application/session_controller.dart';

class ChallengesPage extends ConsumerStatefulWidget {
  const ChallengesPage({super.key});
  @override
  ConsumerState<ChallengesPage> createState() => _ChallengesPageState();
}

class _ChallengesPageState extends ConsumerState<ChallengesPage> {
  int _filter = 0;
  static const _filters = ['Ongoing', 'Upcoming', 'Completed'];
  @override
  Widget build(BuildContext context) {
    final challenges = PreviewData.challenges
        .where((e) => e.status == _filters[_filter])
        .toList();
    final kg = ref.watch(impactProvider).kg;
    return AppPage(
      title: 'Challenges',
      child: Column(
        children: [
          FilterTabs(
            labels: _filters,
            selected: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < challenges.length; i++) ...[
            EcoCard(
              padding: EdgeInsets.zero,
              onTap: () => _details(challenges[i]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (i == 0)
                    const ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: LandscapeArt(height: 100, campus: true),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (i > 0) ...[
                          Container(
                            width: 51,
                            height: 69,
                            decoration: const BoxDecoration(
                              color: AppColors.paleGreen,
                              borderRadius: AppRadius.small,
                            ),
                            child: Icon(
                              challenges[i].art == 'plastic'
                                  ? Icons.recycling_rounded
                                  : Icons.park_rounded,
                              size: 36,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                challenges[i].name,
                                style: AppText.label.copyWith(fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                challenges[i].description,
                                style: AppText.caption.copyWith(
                                  color: AppColors.ink,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      challenges[i].time,
                                      style: AppText.caption,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ClipRRect(
                                borderRadius: AppRadius.pill,
                                child: LinearProgressIndicator(
                                  value:
                                      ((challenges[i].name == 'Campus Clean-up'
                                                  ? kg
                                                  : challenges[i].progress) /
                                              challenges[i].goal)
                                          .clamp(0, 1),
                                  minHeight: 7,
                                  backgroundColor: AppColors.paleGreen,
                                  color: AppColors.leaf,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${(challenges[i].name == 'Campus Clean-up' ? kg : challenges[i].progress).toStringAsFixed(1)} / ${challenges[i].goal.toInt()} kg',
                                  style: AppText.caption.copyWith(fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, size: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 8),
          const PreviewNote(),
        ],
      ),
    );
  }

  void _details(Challenge challenge) => previewNotice(
    context,
    challenge.name,
    '${challenge.description}. ${challenge.time}.\n\n${challenge.status == 'Ongoing'
        ? 'Save a preview plogging session to see your impact grow.'
        : challenge.status == 'Upcoming'
        ? 'This sample challenge opens soon.'
        : 'You completed this sample challenge. Well done!'}\n\nChallenges and rewards are demo data.',
  );
}

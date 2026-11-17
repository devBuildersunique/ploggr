import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/preview/preview_data.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../../shared/widgets/eco_art.dart';
import '../plogging/application/session_controller.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});
  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  int _period = 1;
  @override
  Widget build(BuildContext context) {
    final additionalKg = ref.watch(impactProvider).kg - 12.4;
    double score(RankEntry entry) =>
        entry.score(_period) + (entry.name == 'You' ? additionalKg : 0);
    final entries = [...PreviewData.ranks]
      ..sort((a, b) => score(b).compareTo(score(a)));
    return AppPage(
      title: 'Leaderboard',
      child: Column(
        children: [
          FilterTabs(
            labels: const ['This Week', 'This Month', 'All Time'],
            selected: _period,
            onChanged: (value) => setState(() => _period = value),
          ),
          const SizedBox(height: 20),
          for (var i = 0; i < entries.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              decoration: BoxDecoration(
                color: entries[i].name == 'You'
                    ? AppColors.paleGreen
                    : Colors.transparent,
                borderRadius: AppRadius.small,
                border: entries[i].name == 'You'
                    ? null
                    : const Border(
                        bottom: BorderSide(color: AppColors.border, width: .7),
                      ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 27,
                    child: i < 3
                        ? Icon(
                            Icons.emoji_events_rounded,
                            color: [
                              AppColors.gold,
                              const Color(0xFF939CA7),
                              const Color(0xFFE6843B),
                            ][i],
                            size: 25,
                          )
                        : Text(
                            '${i + 1}',
                            textAlign: TextAlign.center,
                            style: AppText.label,
                          ),
                  ),
                  const SizedBox(width: 10),
                  PersonAvatar(index: entries[i].avatar, radius: 19),
                  const SizedBox(width: 12),
                  Expanded(child: Text(entries[i].name, style: AppText.label)),
                  const SizedBox(width: 6),
                  Text(
                    '${score(entries[i]).toStringAsFixed(1)} kg',
                    style: AppText.label.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          const PreviewNote(
            text: 'Sample rankings · every little bit makes a difference',
          ),
        ],
      ),
    );
  }
}

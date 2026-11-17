import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/preview/preview_data.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../../shared/widgets/preview_map.dart';
import 'cleanup_controller.dart';

class CleanupsPage extends ConsumerStatefulWidget {
  const CleanupsPage({super.key});
  @override
  ConsumerState<CleanupsPage> createState() => _CleanupsPageState();
}

class _CleanupsPageState extends ConsumerState<CleanupsPage> {
  int _tab = 0, _selected = 0;
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Nearby Clean-ups',
    scroll: false,
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: FilterTabs(
            labels: const ['Map', 'List'],
            selected: _tab,
            onChanged: (value) => setState(() => _tab = value),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _tab == 0
              ? Column(
                  children: [
                    Expanded(
                      child: PreviewMap(
                        cleanups: true,
                        selected: _selected,
                        onMarkerTap: (index) =>
                            setState(() => _selected = index),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _eventCard(
                      PreviewData.cleanups[_selected %
                          PreviewData.cleanups.length],
                    ),
                  ],
                )
              : ListView.separated(
                  itemCount: PreviewData.cleanups.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) =>
                      _eventCard(PreviewData.cleanups[index]),
                ),
        ),
        const SizedBox(height: 12),
        const PreviewNote(
          text: 'Sample events · joining stays in this preview',
        ),
      ],
    ),
  );
  Widget _eventCard(Cleanup event) {
    final joined = ref.watch(joinedCleanupsProvider).contains(event.id);
    return EcoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(event.name, style: AppText.heading),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  '${event.distance} · ${event.date}',
                  style: AppText.caption.copyWith(color: AppColors.ink),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(event.location, style: AppText.caption),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.groups_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '${event.attendees + (joined ? 1 : 0)} going',
                  style: AppText.label,
                ),
              ),
              FilledButton(
                onPressed: () {
                  ref.read(joinedCleanupsProvider.notifier).toggle(event.id);
                  toast(
                    context,
                    joined
                        ? 'Left the sample clean-up.'
                        : 'Joined in preview. No registration was sent.',
                  );
                },
                child: Text(joined ? 'Joined ✓' : 'Join'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

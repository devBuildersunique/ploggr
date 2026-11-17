import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../../shared/widgets/preview_map.dart';
import '../plogging/application/session_controller.dart';

class InSessionPage extends ConsumerWidget {
  const InSessionPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sessionProvider);
    void finish() {
      ref.read(sessionProvider.notifier).finish();
      openPage(context, AppRoutes.sessionSummary);
    }

    return AppPage(
      title: 'Plogging in Progress',
      bottomAction: PrimaryButton('Add Details', onPressed: finish),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(state.elapsed, textAlign: TextAlign.center, style: AppText.hero),
          const SizedBox(height: 4),
          PreviewNote(
            text: state.paused
                ? 'Preview session · paused'
                : 'Preview session · simulated activity',
          ),
          const SizedBox(height: 16),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StatTile(
                  value: '2.8 km',
                  label: 'Distance',
                  icon: Icons.route_rounded,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: '5.6 km/h',
                  label: 'Avg. speed',
                  icon: Icons.speed_rounded,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: '320 kcal',
                  label: 'Energy',
                  icon: Icons.local_fire_department_rounded,
                  color: Color(0xFFF68323),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * .42,
            child: Stack(
              children: [
                Positioned.fill(
                  child: PreviewMap(
                    route: true,
                    onMarkerTap: (_) => openPage(context, AppRoutes.map),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filled(
                        tooltip: 'View litter map',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        onPressed: () => openPage(context, AppRoutes.map),
                        icon: const Icon(Icons.map_outlined),
                      ),
                      IconButton.filled(
                        tooltip: state.paused
                            ? 'Resume session'
                            : 'Pause session',
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.coral,
                          minimumSize: const Size(68, 68),
                          side: const BorderSide(color: Colors.white, width: 4),
                        ),
                        onPressed: () {
                          if (!state.active && !state.paused) {
                            ref.read(sessionProvider.notifier).start();
                          } else {
                            ref.read(sessionProvider.notifier).togglePause();
                          }
                        },
                        icon: Icon(
                          state.paused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          size: 32,
                        ),
                      ),
                      IconButton.filled(
                        tooltip: 'End session',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.ink,
                        ),
                        onPressed: finish,
                        icon: const Icon(Icons.stop_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          EcoCard(
            onTap: () => openPage(context, AppRoutes.map),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF1D7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.coral,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('3 nearby litter spots ahead', style: AppText.label),
                      Text('Tap to view and pick up', style: AppText.caption),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

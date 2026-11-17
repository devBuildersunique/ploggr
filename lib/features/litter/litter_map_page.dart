import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../../shared/widgets/preview_map.dart';
import '../../shared/widgets/bottom_navigation.dart';
import 'application/litter_controller.dart';

class LitterMapPage extends ConsumerStatefulWidget {
  const LitterMapPage({super.key});
  @override
  ConsumerState<LitterMapPage> createState() => _LitterMapPageState();
}

class _LitterMapPageState extends ConsumerState<LitterMapPage> {
  int _selected = 0;
  final _mapController = TransformationController();
  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reports = ref.watch(litterProvider);
    final report = reports[_selected % reports.length];
    return AppPage(
      title: 'Litter Map',
      scroll: false,
      bottomNavigation: const BottomNavBar(caller: 'explore'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FilterTabs(
              labels: const ['Litter Spots', 'Clean-ups'],
              selected: 0,
              onChanged: (index) {
                if (index == 1) openPage(context, AppRoutes.cleanups);
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: PreviewMap(
                    controller: _mapController,
                    selected: _selected,
                    onMarkerTap: (index) => setState(() => _selected = index),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 12,
                  child: IconButton.filled(
                    tooltip: 'Reset sample map',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.ink,
                    ),
                    onPressed: () {
                      _mapController.value = Matrix4.identity();
                      setState(() => _selected = 0);
                    },
                    icon: const Icon(Icons.my_location_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          EcoCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LitterPhoto(width: 70, height: 76),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${report.type} Litter', style: AppText.label),
                      const SizedBox(height: 4),
                      const Text(
                        '~ 200 m away · sample spot',
                        style: AppText.caption,
                      ),
                      if (reports.length > 1)
                        Text(
                          report.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption,
                        ),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: () => previewNotice(
                            context,
                            'Sample route',
                            'This illustrative map does not provide directions. The sample litter spot is near City Lake. Live GPS and navigation will be added in a later milestone.',
                          ),
                          child: const Text('Navigate'),
                        ),
                      ),
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

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../plogging/application/session_controller.dart';

class EndSessionPage extends ConsumerWidget {
  const EndSessionPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final controller = ref.read(sessionProvider.notifier);
    return AppPage(
      title: 'End Plog Session',
      backTo: AppRoutes.session,
      bottomAction: PrimaryButton(
        session.saved ? 'Session Saved' : 'Save Session',
        onPressed: session.saved
            ? null
            : () {
                if (controller.save()) {
                  switchPage(context, AppRoutes.home);
                  toast(
                    context,
                    'Session saved in this preview. Your impact has been updated!',
                  );
                }
              },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle('Session Summary'),
          EcoCard(
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 19),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text('Nov 17, 2026, Tue', style: AppText.body),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 26,
                  runSpacing: 12,
                  children: [
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.route_rounded, size: 20),
                        SizedBox(width: 8),
                        Text('2.8 km'),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(session.elapsed),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SectionTitle('Collected Litter'),
          EcoCard(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Decrease litter weight',
                  onPressed: session.kg > 0
                      ? () => controller.setWeight(session.kg - .5)
                      : null,
                  icon: const Icon(
                    Icons.remove_rounded,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${session.kg.toStringAsFixed(1)} kg',
                    textAlign: TextAlign.center,
                    style: AppText.heading,
                  ),
                ),
                IconButton(
                  tooltip: 'Increase litter weight',
                  onPressed: () => controller.setWeight(session.kg + .5),
                  icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const SectionTitle('Litter Type (optional)'),
          LitterTypePicker(
            selected: session.litterType,
            onChanged: controller.selectType,
          ),
          SectionTitle('Photos (${session.photos})'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < session.photos; i++)
                SizedBox(
                  width: 72,
                  height: 78,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const LitterPhoto(),
                      Align(
                        alignment: Alignment.topRight,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: IconButton(
                            tooltip: 'Remove sample photo ${i + 1}',
                            onPressed: controller.removePhoto,
                            icon: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (session.photos < 6)
                SizedBox(
                  width: 72,
                  height: 78,
                  child: OutlinedButton(
                    onPressed: controller.addPhoto,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.paleGreen,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      semanticLabel: 'Add sample session photo',
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          const PreviewNote(
            text: 'Sample activity and photos · saved for this app run only',
          ),
        ],
      ),
    );
  }
}

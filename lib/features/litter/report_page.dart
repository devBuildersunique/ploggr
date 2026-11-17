import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/preview/preview_data.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';
import 'application/litter_controller.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});
  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  String _type = 'Plastic';
  String _location = PreviewData.coordinates;
  bool _photo = true;
  final _description = TextEditingController();
  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Report Litter',
    bottomAction: PrimaryButton(
      'Add to Litter Map',
      onPressed: () {
        if (!_photo) {
          toast(context, 'Add the sample photo before saving your report.');
          return;
        }
        ref
            .read(litterProvider.notifier)
            .add(
              type: _type,
              description: _description.text.trim(),
              location: _location,
            );
        switchPage(context, AppRoutes.map);
        toast(context, 'Sample report added to your preview map.');
      },
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(
            width: 208,
            height: 150,
            child: _photo
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      const LitterPhoto(),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          tooltip: 'Remove sample photo',
                          onPressed: () => setState(() => _photo = false),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.ink,
                            foregroundColor: Colors.white,
                          ),
                          icon: const Icon(Icons.close_rounded, size: 20),
                        ),
                      ),
                    ],
                  )
                : OutlinedButton.icon(
                    onPressed: () => setState(() => _photo = true),
                    icon: const Icon(Icons.add_a_photo_outlined),
                    label: const Text('Add sample photo'),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        const PreviewNote(text: 'Preview · sample photo and location'),
        const SectionTitle('Litter Type *'),
        LitterTypePicker(
          selected: _type,
          onChanged: (value) => setState(() => _type = value),
        ),
        const SectionTitle('Location'),
        EcoCard(
          onTap: _editLocation,
          padding: const EdgeInsets.fromLTRB(12, 3, 4, 3),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text(_location, style: AppText.label)),
              IconButton(
                tooltip: 'Change sample location',
                onPressed: _editLocation,
                icon: const Icon(
                  Icons.edit_location_alt_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Description (optional)'),
        TextField(
          controller: _description,
          maxLines: 3,
          maxLength: 250,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'e.g. plastic bottle near the lakeside',
            semanticCounterText: '250 characters maximum',
          ),
        ),
      ],
    ),
  );
  Future<void> _editLocation() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Choose a sample location', style: AppText.heading),
            ),
            for (final location in [
              PreviewData.coordinates,
              'Green Park · north entrance',
              'City Lake · walking trail',
            ])
              ListTile(
                leading: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.primary,
                ),
                title: Text(location),
                onTap: () => Navigator.pop(context, location),
              ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: PreviewNote(text: 'No GPS location is accessed.'),
            ),
          ],
        ),
      ),
    );
    if (choice != null && mounted) setState(() => _location = choice);
  }
}

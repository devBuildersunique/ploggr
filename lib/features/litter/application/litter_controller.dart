import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/preview/preview_data.dart';

final litterProvider = NotifierProvider<LitterController, List<LitterReport>>(
  LitterController.new,
);

class LitterReport {
  const LitterReport({
    required this.id,
    required this.type,
    this.description = '',
    this.location = PreviewData.coordinates,
  });
  final String id, type, description, location;
}

class LitterController extends Notifier<List<LitterReport>> {
  @override
  List<LitterReport> build() => const [
    LitterReport(
      id: 'sample',
      type: 'Plastic',
      description: 'A bottle beside the lakeside trail.',
    ),
  ];
  void add({
    required String type,
    required String description,
    required String location,
  }) => state = [
    LitterReport(
      id: 'preview-${state.length}',
      type: type,
      description: description,
      location: location,
    ),
    ...state,
  ];
}

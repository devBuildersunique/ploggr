import 'package:material_ui/material_ui.dart';
import 'ploggr_ui.dart';

void showCustomMessage(
  BuildContext context, {
  required String title,
  required String description,
}) => previewNotice(context, title, description);
void showWipPopup(
  BuildContext context, {
  required String title,
  required String description,
}) => previewNotice(context, title, description);

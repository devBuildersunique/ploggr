import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../routes/app_routes.dart';

export '../../core/constants/app_colors.dart';
export '../../core/theme/app_tokens.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.bottomNavigation,
    this.bottomAction,
    this.actions,
    this.scroll = true,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 24),
    this.backTo = AppRoutes.home,
  });
  final String title;
  final Widget child;
  final Widget? bottomNavigation;
  final Widget? bottomAction;
  final List<Widget>? actions;
  final bool scroll;
  final EdgeInsets padding;
  final String backTo;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back_rounded, size: 22),
        onPressed: () => goBack(context, fallback: backTo),
      ),
      title: Text(title, maxLines: 2, textAlign: TextAlign.center),
      actions: actions ?? [const SizedBox(width: 48)],
    ),
    body: SafeArea(
      top: false,
      bottom: bottomNavigation == null && bottomAction == null,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: scroll
              ? SingleChildScrollView(
                  key: const PageStorageKey('page-scroll'),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: padding,
                  child: child,
                )
              : Padding(padding: padding, child: child),
        ),
      ),
    ),
    bottomNavigationBar:
        bottomNavigation ??
        (bottomAction == null
            ? null
            : SafeArea(
                top: false,
                child: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: bottomAction,
                    ),
                  ),
                ),
              )),
  );
}

// Transient feedback belongs to the originating screen. Clear it before
// navigation so it never covers controls (especially the camera shutter).
void openPage(BuildContext context, String location) {
  ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
  context.push(location);
}

void switchPage(BuildContext context, String location) {
  ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
  context.go(location);
}

void goBack(BuildContext context, {String fallback = AppRoutes.home}) {
  ScaffoldMessenger.maybeOf(context)?.removeCurrentSnackBar();
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(fallback);
  }
}

void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<void> previewNotice(
  BuildContext context,
  String title,
  String message,
) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    icon: const Icon(Icons.eco_outlined, color: AppColors.primary, size: 32),
    title: Text(title),
    content: Text(message),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Got it'),
      ),
    ],
  ),
);

class PreviewNote extends StatelessWidget {
  const PreviewNote({
    super.key,
    this.text = 'Preview · sample data',
    this.light = false,
  });
  final String text;
  final bool light;
  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: TextAlign.center,
    style: AppText.caption.copyWith(
      fontSize: 11,
      color: light ? Colors.white.withValues(alpha: .85) : AppColors.muted,
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22),
            const SizedBox(width: 10),
          ],
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    ),
  );
}

class EcoCard extends StatelessWidget {
  const EcoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = AppColors.surface,
  });
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      borderRadius: AppRadius.card,
      boxShadow: AppShadows.soft,
    ),
    child: Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: const BorderSide(color: AppColors.border, width: .7),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(text, style: AppText.heading.copyWith(fontSize: 18)),
        ),
        ?trailing,
      ],
    ),
  );
}

class FilterTabs extends StatelessWidget {
  const FilterTabs({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
  });
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F3EE),
      borderRadius: AppRadius.pill,
      border: Border.all(color: AppColors.border),
    ),
    child: Row(
      children: List.generate(
        labels.length,
        (index) => Expanded(
          child: Semantics(
            selected: index == selected,
            child: Material(
              color: selected == index ? AppColors.primary : Colors.transparent,
              borderRadius: AppRadius.pill,
              child: InkWell(
                borderRadius: AppRadius.pill,
                onTap: () => onChanged(index),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10,
                    ),
                    child: Center(
                      child: Text(
                        labels[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                          color: selected == index
                              ? Colors.white
                              : AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
    this.onTap,
  });
  final String value;
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => EcoCard(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 7),
        ],
        Text(
          value,
          style: AppText.heading.copyWith(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppText.caption.copyWith(fontSize: 11, color: AppColors.ink),
        ),
      ],
    ),
  );
}

class AppField extends StatefulWidget {
  const AppField({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.password = false,
    this.keyboardType,
    this.validator,
    this.onSubmitted,
    this.textInputAction = TextInputAction.next,
  });
  final String label;
  final IconData icon;
  final TextEditingController? controller;
  final bool password;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction textInputAction;
  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool hidden = true;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    obscureText: widget.password && hidden,
    enableSuggestions: !widget.password,
    autocorrect: !widget.password,
    keyboardType: widget.keyboardType,
    textInputAction: widget.textInputAction,
    validator: widget.validator,
    onFieldSubmitted: widget.onSubmitted,
    decoration: InputDecoration(
      labelText: widget.label,
      prefixIcon: Icon(widget.icon, size: 21),
      suffixIcon: widget.password
          ? IconButton(
              tooltip: hidden
                  ? 'Show ${widget.label.toLowerCase()}'
                  : 'Hide ${widget.label.toLowerCase()}',
              onPressed: () => setState(() => hidden = !hidden),
              icon: Icon(
                hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.muted,
              ),
            )
          : null,
    ),
  );
}

class LitterTypePicker extends StatelessWidget {
  const LitterTypePicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });
  static const types = [
    'Plastic',
    'Paper',
    'Glass',
    'Metal',
    'E-waste',
    'Other',
  ];
  final String? selected;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      spacing: 8,
      runSpacing: 8,
      children: types
          .map(
            (type) => SizedBox(
              width: (constraints.maxWidth - 16) / 3,
              child: Semantics(
                selected: selected == type,
                child: Material(
                  color: selected == type
                      ? AppColors.primary
                      : AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.pill,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: InkWell(
                    borderRadius: AppRadius.pill,
                    onTap: () => onChanged(type),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 48),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            type,
                            style: AppText.label.copyWith(
                              color: selected == type
                                  ? Colors.white
                                  : AppColors.ink,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    ),
  );
}

class LitterPhoto extends StatelessWidget {
  const LitterPhoto({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });
  final double? height;
  final double? width;
  final BoxFit fit;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: AppRadius.small,
    child: Image.asset(
      'assets/images/demo/litter.png',
      height: height,
      width: width,
      fit: fit,
      semanticLabel: 'Sample photograph of a plastic bottle on a woodland path',
    ),
  );
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../../shared/widgets/eco_art.dart';
import '../../shared/widgets/bottom_navigation.dart';
import '../plogging/application/session_controller.dart';
import '../litter/application/litter_controller.dart';
import 'profile_controller.dart';

enum ProfileSection {
  activity(AppRoutes.activity, 'My Activity', Icons.work_history_outlined),
  saved(AppRoutes.saved, 'Saved Litter Spots', Icons.bookmark_border_rounded),
  settings(AppRoutes.settings, 'Settings', Icons.settings_outlined),
  help(AppRoutes.help, 'Help & Support', Icons.help_outline_rounded),
  about(AppRoutes.about, 'About ploggr', Icons.info_outline_rounded);

  const ProfileSection(this.path, this.title, this.icon);
  final String path;
  final String title;
  final IconData icon;
}

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileProvider);
    final impact = ref.watch(impactProvider);
    return AppPage(
      title: 'Profile',
      bottomNavigation: const BottomNavBar(caller: 'profile'),
      child: Column(
        children: [
          Row(
            children: [
              const PersonAvatar(index: 3, radius: 34),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppText.heading),
                    const SizedBox(height: 4),
                    Text(
                      '@${name.split(' ').first.toLowerCase()}',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit profile',
                onPressed: () => _edit(context, ref, name),
                icon: const Icon(Icons.edit_outlined, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: StatTile(
                  value: '${impact.kg.toStringAsFixed(1)} kg',
                  label: 'Litter Collected',
                  onTap: () => openPage(context, AppRoutes.activity),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: '${impact.sessions}',
                  label: 'Sessions',
                  onTap: () => openPage(context, AppRoutes.activity),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatTile(
                  value: '5',
                  label: 'Badges',
                  onTap: () => openPage(context, AppRoutes.badges),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          EcoCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final section in ProfileSection.values) ...[
                  if (section != ProfileSection.values.first) const Divider(),
                  _row(context, section),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const PreviewNote(
            text: 'Preview profile · your small steps make a big difference',
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, ProfileSection section) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
    leading: Icon(section.icon, size: 22, color: AppColors.ink),
    title: Text(section.title, style: AppText.label.copyWith(fontSize: 14)),
    trailing: const Icon(Icons.chevron_right_rounded, size: 21),
    onTap: () => openPage(context, section.path),
  );

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _EditProfileDialog(name: current),
    );
    if (name != null) ref.read(profileProvider.notifier).rename(name);
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.name});
  final String name;
  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.name,
  );
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Edit preview profile'),
    content: TextField(
      controller: _name,
      autofocus: true,
      maxLength: 40,
      onChanged: (_) => setState(() {}),
      decoration: const InputDecoration(labelText: 'Display name'),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _name.text.trim().isEmpty
            ? null
            : () => Navigator.pop(context, _name.text),
        child: const Text('Save'),
      ),
    ],
  );
}

class ProfileDetailPage extends ConsumerStatefulWidget {
  const ProfileDetailPage({super.key, required this.section});
  final ProfileSection section;
  @override
  ConsumerState<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends ConsumerState<ProfileDetailPage> {
  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: widget.section.title,
      backTo: AppRoutes.profile,
      child: switch (widget.section) {
        ProfileSection.activity => _activity(),
        ProfileSection.saved => _saved(),
        ProfileSection.settings => _settings(),
        ProfileSection.help => const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('A little help for your next plog', style: AppText.title),
            SizedBox(height: 20),
            ExpansionTile(
              title: Text('What is plogging?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Plogging combines walking or jogging with picking up litter. Small steps help care for the places we share.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text('How do I use this preview?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Start a sample session, capture a sample litter photo, join an event, or share a local post. Changes last until the app restarts.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text('Does this use my camera or location?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No. Photos, maps, routes, and activity metrics are illustrative. No camera or location permissions are requested.',
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text('How can I plog thoughtfully?'),
              children: [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Be mindful of your surroundings and fellow walkers. Leave sharp or unknown items for local clean-up services.',
                  ),
                ),
              ],
            ),
          ],
        ),
        ProfileSection.about => const Column(
          children: [
            SizedBox(height: 32),
            PloggrLogo(),
            SizedBox(height: 24),
            Text(
              'Plog today. Change tomorrow.',
              style: AppText.heading,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'A cleaner planet, one step at a time. Ploggr brings movement, environmental care, and community together.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            PreviewNote(
              text:
                  'Version 1.0.0 · design preview\nBuilt with Flutter · all data is local and simulated',
            ),
          ],
        ),
      },
    );
  }

  Widget _activity() {
    final impact = ref.watch(impactProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${impact.sessions} sessions. A lasting impact.',
          style: AppText.title,
        ),
        const SizedBox(height: 8),
        Text(
          '${impact.kg.toStringAsFixed(1)} kg collected in your preview profile.',
        ),
        const SizedBox(height: 24),
        for (final session in impact.savedSessions) ...[
          EcoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your latest plog', style: AppText.heading),
                const SizedBox(height: 6),
                Text(
                  '${session.kg.toStringAsFixed(1)} kg · ${session.duration} · ${session.litterType}',
                ),
                const SizedBox(height: 4),
                Text(
                  '${session.date.day}/${session.date.month}/${session.date.year} · saved locally',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        const EcoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Lakeside morning plog', style: AppText.heading),
              SizedBox(height: 6),
              Text('2.1 kg · 3.2 km · 32 min'),
              SizedBox(height: 4),
              Text('Nov 15, 2026 · sample activity', style: AppText.caption),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const PreviewNote(),
      ],
    );
  }

  Widget _saved() => Column(
    children: [
      for (final report in ref.watch(litterProvider)) ...[
        EcoCard(
          onTap: () => openPage(context, AppRoutes.map),
          child: Row(
            children: [
              const LitterPhoto(width: 64, height: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${report.type} Litter', style: AppText.label),
                    Text(report.location, style: AppText.caption),
                    if (report.description.isNotEmpty)
                      Text(
                        report.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption,
                      ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
      const PreviewNote(
        text: 'Your sample reports are saved here until restart.',
      ),
    ],
  );
  Widget _settings() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const EcoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You’re exploring the preview', style: AppText.heading),
            SizedBox(height: 8),
            Text(
              'Your preview activity and profile details stay on this device. '
              'A connection check contacts the configured server. '
              'Authentication, notifications, live tracking, and cloud storage are not connected.',
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      ListTile(
        leading: const Icon(Icons.network_check, color: AppColors.primary),
        title: const Text('Connection check'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => openPage(context, AppRoutes.connection),
      ),
      ListTile(
        leading: const Icon(Icons.slideshow_rounded, color: AppColors.primary),
        title: const Text('Replay onboarding'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => switchPage(context, AppRoutes.onboarding),
      ),
      ListTile(
        leading: const Icon(Icons.logout_rounded, color: AppColors.primary),
        title: const Text('Leave preview'),
        subtitle: const Text('Return to the welcome screen'),
        onTap: () => switchPage(context, AppRoutes.login),
      ),
      const SizedBox(height: 20),
      const PreviewNote(
        text: 'Appearance follows the reference’s light green theme.',
      ),
    ],
  );
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../../shared/widgets/eco_art.dart';
import '../../shared/widgets/bottom_navigation.dart';
import '../profile/profile_controller.dart';
import 'community_controller.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});
  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage> {
  int _tab = 0;
  @override
  Widget build(BuildContext context) {
    final posts = ref
        .watch(communityProvider)
        .where((p) => _tab == 0 || p.mine)
        .toList();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => goBack(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Community'),
        actions: const [SizedBox(width: 48)],
      ),
      bottomNavigationBar: const BottomNavBar(caller: 'community'),
      floatingActionButton: FloatingActionButton.small(
        tooltip: 'Write a preview post',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: _compose,
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              children: [
                FilterTabs(
                  labels: const ['Feed', 'My Posts'],
                  selected: _tab,
                  onChanged: (value) => setState(() => _tab = value),
                ),
                const SizedBox(height: 10),
                const PreviewNote(
                  text:
                      'Preview community · posts stay on this device until restart',
                ),
                const SizedBox(height: 12),
                if (posts.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      'Your story starts here.\nTap + to share a preview update.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                for (final post in posts) ...[
                  _post(post),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _post(CommunityPost post) => EcoCard(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PersonAvatar(index: post.avatar, radius: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    children: [
                      Text(
                        post.mine ? ref.watch(profileProvider) : post.author,
                        style: AppText.label,
                      ),
                      Text(
                        '· ${post.time}',
                        style: AppText.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(post.text, style: AppText.body.copyWith(fontSize: 13)),
                ],
              ),
            ),
            SizedBox(
              width: 48,
              child: PopupMenuButton<String>(
                tooltip: 'Post options',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_horiz_rounded, size: 20),
                onSelected: (action) {
                  if (action == 'delete') {
                    ref.read(communityProvider.notifier).delete(post.id);
                  } else {
                    previewNotice(
                      context,
                      'Sample community post',
                      'This is a fictional post included to demonstrate the community experience.',
                    );
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: post.mine ? 'delete' : 'info',
                    child: Text(
                      post.mine
                          ? 'Delete preview post'
                          : 'About this sample post',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (post.photo) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: () => openPage(context, AppRoutes.map),
            child: Stack(
              children: [
                const LitterPhoto(height: 174, width: double.infinity),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.pill,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.coral,
                        ),
                        SizedBox(width: 4),
                        Text('Litter Spot', style: AppText.label),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 4),
        Row(
          children: [
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: post.liked ? AppColors.coral : AppColors.ink,
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
              onPressed: () =>
                  ref.read(communityProvider.notifier).like(post.id),
              icon: Icon(
                post.liked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 20,
                color: AppColors.coral,
              ),
              label: Text('${post.likes}'),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: AppColors.ink),
              onPressed: () => _comments(post.id),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19),
              label: Text('${post.comments.length}'),
            ),
          ],
        ),
      ],
    ),
  );
  Future<void> _compose() async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => const _ComposeDialog(),
    );
    if (text != null && text.trim().isNotEmpty && mounted) {
      ref
          .read(communityProvider.notifier)
          .publish(ref.read(profileProvider), text);
      toast(context, 'Post added to the local preview.');
    }
  }

  void _comments(String id) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _CommentsSheet(postId: id),
  );
}

class _ComposeDialog extends StatefulWidget {
  const _ComposeDialog();
  @override
  State<_ComposeDialog> createState() => _ComposeDialogState();
}

class _ComposeDialogState extends State<_ComposeDialog> {
  final _text = TextEditingController();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Share a little good'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _text,
            autofocus: true,
            maxLines: 4,
            maxLength: 400,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'How was your plog today?',
            ),
          ),
          const PreviewNote(
            text: 'Visible in this preview only. Nothing is published online.',
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _text.text.trim().isEmpty
            ? null
            : () => Navigator.pop(context, _text.text),
        child: const Text('Add Post'),
      ),
    ],
  );
}

class _CommentsSheet extends ConsumerStatefulWidget {
  const _CommentsSheet({required this.postId});
  final String postId;
  @override
  ConsumerState<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<_CommentsSheet> {
  final _text = TextEditingController();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = ref
        .watch(communityProvider)
        .firstWhere((p) => p.id == widget.postId);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .45,
          child: Column(
            children: [
              const Text('Preview comments', style: AppText.heading),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (final comment in post.comments)
                      ListTile(
                        leading: const Icon(
                          Icons.chat_bubble_outline,
                          color: AppColors.primary,
                        ),
                        title: Text(comment, style: AppText.body),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _text,
                      maxLength: 200,
                      decoration: const InputDecoration(
                        hintText: 'Add a local comment',
                        counterText: '',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add comment',
                    onPressed: () {
                      ref
                          .read(communityProvider.notifier)
                          .comment(widget.postId, _text.text);
                      _text.clear();
                    },
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

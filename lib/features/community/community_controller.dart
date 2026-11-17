import 'package:flutter_riverpod/flutter_riverpod.dart';

final communityProvider =
    NotifierProvider<CommunityController, List<CommunityPost>>(
      CommunityController.new,
    );

class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.author,
    required this.text,
    required this.avatar,
    this.time = 'Just now',
    this.photo = false,
    this.mine = false,
    this.liked = false,
    this.likes = 0,
    this.comments = const [],
  });
  final String id, author, text, time;
  final int avatar, likes;
  final bool photo, mine, liked;
  final List<String> comments;
  CommunityPost copyWith({bool? liked, int? likes, List<String>? comments}) =>
      CommunityPost(
        id: id,
        author: author,
        text: text,
        avatar: avatar,
        time: time,
        photo: photo,
        mine: mine,
        liked: liked ?? this.liked,
        likes: likes ?? this.likes,
        comments: comments ?? this.comments,
      );
}

class CommunityController extends Notifier<List<CommunityPost>> {
  @override
  List<CommunityPost> build() => const [
    CommunityPost(
      id: 'ananya',
      author: 'Ananya P.',
      text:
          'Spotted a lot of plastic near the lake. Added it on the litter map! ♻️',
      avatar: 1,
      time: '2h ago',
      photo: true,
      likes: 42,
      comments: [
        'Thanks for sharing the spot!',
        'Let’s clean this up together.',
      ],
    ),
    CommunityPost(
      id: 'rohit',
      author: 'Rohit S.',
      text: 'Completed a 5 km plog today. Collected 3.1 kg! 💪',
      avatar: 0,
      time: '5h ago',
      likes: 28,
    ),
    CommunityPost(
      id: 'me',
      author: 'Vipul Reddy',
      text: 'A little walk. A cleaner neighbourhood. Every step counts. 🌱',
      avatar: 3,
      time: 'Yesterday',
      mine: true,
      likes: 12,
    ),
  ];
  void like(String id) => state = [
    for (final p in state)
      if (p.id == id)
        p.copyWith(liked: !p.liked, likes: p.likes + (p.liked ? -1 : 1))
      else
        p,
  ];
  void comment(String id, String text) {
    if (text.trim().isEmpty) return;
    state = [
      for (final p in state)
        if (p.id == id)
          p.copyWith(comments: [...p.comments, text.trim()])
        else
          p,
    ];
  }

  void publish(String author, String text) {
    if (text.trim().isEmpty) return;
    state = [
      CommunityPost(
        id: 'local-${state.length}',
        author: author,
        text: text.trim(),
        avatar: 3,
        mine: true,
      ),
      ...state,
    ];
  }

  void delete(String id) =>
      state = state.where((p) => !(p.id == id && p.mine)).toList();
}

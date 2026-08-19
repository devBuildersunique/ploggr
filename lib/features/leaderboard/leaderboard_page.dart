import 'package:flutter/material.dart';
import 'package:ploggr/features/util/bottom_navigation.dart';

// ---- Palette ----------------------------------------------------------------
const kOrange = Color(0xFFF7941D);
const kDeepBrown = Color(0xFF6B3A0E);
const kCardBg = Colors.white;
const kPageBg = Color(0xFFFBF3EF);
const kTextGrey = Color(0xFF8A8A8A);
const kOliveGreen = Color(0xFF5E6814);
const kLightBrown = Color(0xFF7A634E);

// ---- Data Model -------------------------------------------------------------
class LeaderboardEntry {
  final int rank;
  final String name;
  final double score;
  final String avatarUrl;
  final bool isMe;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    required this.score,
    required this.avatarUrl,
    this.isMe = false,
  });
}

// Extended Mock Data for interactivity
final List<LeaderboardEntry> globalData = [
  LeaderboardEntry(rank: 1, name: 'David', score: 20.5, avatarUrl: 'https://i.pravatar.cc/150?img=11'),
  LeaderboardEntry(rank: 2, name: 'Sarah', score: 18.2, avatarUrl: 'https://i.pravatar.cc/150?img=5'),
  LeaderboardEntry(rank: 3, name: 'Mike', score: 15.0, avatarUrl: 'https://i.pravatar.cc/150?img=12'),
  LeaderboardEntry(rank: 4, name: 'Priya Sharma', score: 14.2, avatarUrl: 'https://i.pravatar.cc/150?img=9'),
  LeaderboardEntry(rank: 5, name: 'Jordan Lee', score: 13.5, avatarUrl: 'https://i.pravatar.cc/150?img=15'),
  LeaderboardEntry(rank: 6, name: 'Emma Wilson', score: 12.8, avatarUrl: 'https://i.pravatar.cc/150?img=20'),
  LeaderboardEntry(rank: 7, name: 'Chris Evans', score: 12.1, avatarUrl: 'https://i.pravatar.cc/150?img=18'),
  LeaderboardEntry(rank: 8, name: 'Olivia Brown', score: 11.5, avatarUrl: 'https://i.pravatar.cc/150?img=22'),
  LeaderboardEntry(rank: 9, name: 'Liam Smith', score: 10.9, avatarUrl: 'https://i.pravatar.cc/150?img=33'),
  LeaderboardEntry(rank: 10, name: 'Yatish Kumar Ray (Me)', score: 9.8, avatarUrl: 'https://i.pravatar.cc/150?img=47', isMe: true),
  LeaderboardEntry(rank: 11, name: 'Sophia Davis', score: 9.2, avatarUrl: 'https://i.pravatar.cc/150?img=24'),
  LeaderboardEntry(rank: 12, name: 'Mason Miller', score: 8.5, avatarUrl: 'https://i.pravatar.cc/150?img=25'),
];

final List<LeaderboardEntry> friendsData = [
  LeaderboardEntry(rank: 1, name: 'Sarah', score: 18.2, avatarUrl: 'https://i.pravatar.cc/150?img=5'),
  LeaderboardEntry(rank: 2, name: 'Yatish Kumar Ray (Me)', score: 9.8, avatarUrl: 'https://i.pravatar.cc/150?img=47', isMe: true),
  LeaderboardEntry(rank: 3, name: 'Priya Sharma', score: 6.2, avatarUrl: 'https://i.pravatar.cc/150?img=9'),
  LeaderboardEntry(rank: 4, name: 'Jordan Lee', score: 4.5, avatarUrl: 'https://i.pravatar.cc/150?img=15'),
];

// ---- Main Page --------------------------------------------------------------
class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool _isGlobalSelected = true;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _meItemKey = GlobalKey();

  void _scrollToMe() {
    if (_meItemKey.currentContext != null) {
      Scrollable.ensureVisible(
        _meItemKey.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        alignment: 0.5, // Centers the item vertically in the viewport
      );
    } else {
      // If the item isn't built yet, scroll to bottom as a fallback
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeData = _isGlobalSelected ? globalData : friendsData;
    
    // Separate top 3 from the rest of the list safely
    final topThree = activeData.take(3).toList();
    final listRanks = activeData.skip(3).toList();

    // Find current user's rank in the active list
    final meEntry = activeData.firstWhere(
      (e) => e.isMe,
      orElse: () => LeaderboardEntry(rank: 0, name: 'N/A', score: 0, avatarUrl: ''),
    );

    return Scaffold(
      backgroundColor: kPageBg,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  child: Stack(
                    children: [
                      const _HeaderBackground(),
                      Column(
                        children: [
                          const SafeArea(
                            bottom: false,
                            child: SizedBox(height: 20),
                          ),
                          const Text(
                            'Leaderboard',
                            style: TextStyle(
                              color: kDeepBrown,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _GlobalFriendsToggle(
                            isGlobalSelected: _isGlobalSelected,
                            onToggle: (isGlobal) {
                              setState(() {
                                _isGlobalSelected = isGlobal;
                              });
                              // Optional: Reset scroll to top when changing tabs
                              _scrollController.jumpTo(0);
                            },
                          ),
                          const SizedBox(height: 40),
                          if (topThree.isNotEmpty) ...[
                            _PodiumSection(
                              topThree: topThree,
                              meKey: _meItemKey,
                            ),
                            const SizedBox(height: 20),
                          ],
                          _RankList(
                            listRanks: listRanks,
                            meKey: _meItemKey,
                          ),
                          const SizedBox(height: 100), // padding for floating bubble
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const BottomNavBar(caller: 'ranks'),
            ],
          ),
          
          // Interactive Floating "Me" badge
          if (meEntry.rank != 0)
            Positioned(
              bottom: 100,
              right: 30,
              child: GestureDetector(
                onTap: _scrollToMe,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: kOrange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kOrange.withOpacity(0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Me',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '#${meEntry.rank}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---- Header Background ------------------------------------------------------
class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground();

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _HeaderClipper(),
      child: Container(
        height: 280,
        width: double.infinity,
        color: kOrange,
      ),
    );
  }
}

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.lineTo(size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// ---- Interactive Toggle Button ----------------------------------------------
class _GlobalFriendsToggle extends StatelessWidget {
  final bool isGlobalSelected;
  final ValueChanged<bool> onToggle;

  const _GlobalFriendsToggle({
    required this.isGlobalSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(true),
              behavior: HitTestBehavior.opaque,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isGlobalSelected ? kDeepBrown : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Global',
                  style: TextStyle(
                    color: isGlobalSelected ? Colors.white : Colors.black87,
                    fontSize: 15,
                    fontWeight: isGlobalSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(false),
              behavior: HitTestBehavior.opaque,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isGlobalSelected ? kDeepBrown : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Friends',
                  style: TextStyle(
                    color: !isGlobalSelected ? Colors.white : Colors.black87,
                    fontSize: 15,
                    fontWeight: !isGlobalSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---- Podium Section ---------------------------------------------------------
class _PodiumSection extends StatelessWidget {
  final List<LeaderboardEntry> topThree;
  final GlobalKey meKey;

  const _PodiumSection({
    required this.topThree,
    required this.meKey,
  });

  @override
  Widget build(BuildContext context) {
    // Safely retrieve entries if the list is smaller than 3 (e.g. Friends tab)
    final first = topThree.isNotEmpty ? topThree[0] : null;
    final second = topThree.length > 1 ? topThree[1] : null;
    final third = topThree.length > 2 ? topThree[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: second != null
                ? _PodiumBar(
                    key: second.isMe ? meKey : null,
                    entry: second,
                    height: 120,
                    color: kOliveGreen,
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: first != null
                ? _PodiumBar(
                    key: first.isMe ? meKey : null,
                    entry: first,
                    height: 160,
                    color: kOrange,
                    isFirst: true,
                  )
                : const SizedBox(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: third != null
                ? _PodiumBar(
                    key: third.isMe ? meKey : null,
                    entry: third,
                    height: 90,
                    color: kLightBrown,
                  )
                : const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class _PodiumBar extends StatelessWidget {
  final LeaderboardEntry entry;
  final double height;
  final Color color;
  final bool isFirst;

  const _PodiumBar({
    super.key,
    required this.entry,
    required this.height,
    required this.color,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: isFirst ? 32 : 24,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: isFirst ? 28 : 22,
            backgroundImage: NetworkImage(entry.avatarUrl),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            entry.rank.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

// ---- Rank List --------------------------------------------------------------
class _RankList extends StatelessWidget {
  final List<LeaderboardEntry> listRanks;
  final GlobalKey meKey;

  const _RankList({
    required this.listRanks,
    required this.meKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: listRanks.map((entry) {
          return Container(
            key: entry.isMe ? meKey : null,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: kCardBg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: entry.isMe ? kOrange : Colors.grey.shade200,
                width: entry.isMe ? 2 : 1,
              ),
              boxShadow: [
                if (entry.isMe)
                  BoxShadow(
                    color: kOrange.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    entry.rank.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: entry.isMe ? FontWeight.bold : FontWeight.w500,
                      color: entry.isMe ? kDeepBrown : Colors.black54,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(entry.avatarUrl),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    entry.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: entry.isMe ? FontWeight.bold : FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: entry.isMe ? kOrange : const Color(0xFFF9EFE5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${entry.score} kg',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: entry.isMe ? Colors.white : kDeepBrown,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---- Bottom Nav Bar ---------------------------------------------------------
// class _BottomNavBar extends StatelessWidget {
//   const _BottomNavBar();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: kCardBg,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 12,
//             offset: const Offset(0, -4),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         top: false,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 10),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: const [
//               _NavItem(icon: Icons.grid_view_rounded, label: 'Home'),
//               _NavItem(icon: Icons.directions_run_rounded, label: 'Track'),
//               _NavItem(icon: Icons.bar_chart_rounded, label: 'Ranks', selected: true),
//               _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NavItem extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final bool selected;

//   const _NavItem({
//     required this.icon,
//     required this.label,
//     this.selected = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final color = selected ? kOrange : kTextGrey;
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (selected)
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: const BoxDecoration(
//               color: kOrange,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(icon, color: Colors.white, size: 20),
//           )
//         else
//           Icon(icon, color: color, size: 24),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 11,
//             color: color,
//             fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
//           ),
//         ),
//       ],
//     );
//   }
// }
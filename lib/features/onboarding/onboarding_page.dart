import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../../shared/widgets/eco_art.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.initialPage = 0});
  final int initialPage;
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _controller;
  late int _page;
  static const _titles = [
    'Plog & Keep\nYour Surroundings Clean',
    'Take Challenges\n& Earn Rewards',
    'Spot Litter, Report &\nClean Together',
  ];
  static const _descriptions = [
    'Pick up litter while you walk,\nrun or cycle.',
    'Join clean-up drives, complete\nchallenges and earn points,\nbadges and more.',
    'Scan and map litter around you\nso ploggers can pick it up\nduring their sessions.',
  ];
  @override
  void initState() {
    super.initState();
    _page = widget.initialPage.clamp(0, 2);
    _controller = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              SizedBox(
                height: 56,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _page < 2
                      ? TextButton(
                          onPressed: () => switchPage(context, AppRoutes.login),
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: 3,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) => SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * .10,
                        ),
                        SizedBox(
                          height: math.min(
                            310,
                            MediaQuery.sizeOf(context).width * .8,
                          ),
                          child: index == 1
                              ? const TrophyArt()
                              : ClipPath(
                                  clipper: _ArtClipper(),
                                  child: Image.asset(
                                    'assets/images/illustrations/${index == 0 ? 'plogging' : 'together'}.png',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: AppSpace.page,
                          child: Text(
                            _titles[index],
                            textAlign: TextAlign.center,
                            style: AppText.title,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: AppSpace.page,
                          child: Text(
                            _descriptions[index],
                            textAlign: TextAlign.center,
                            style: AppText.body.copyWith(fontSize: 17),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: _page == 2
                    ? Column(
                        children: [
                          _dots(),
                          const SizedBox(height: 22),
                          PrimaryButton(
                            'Get Started',
                            onPressed: () =>
                                switchPage(context, AppRoutes.login),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          const SizedBox(width: 50),
                          Expanded(child: _dots()),
                          IconButton.filled(
                            tooltip: 'Next onboarding page',
                            onPressed: () => _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  Widget _dots() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      3,
      (i) => Semantics(
        label: 'Page ${i + 1} of 3',
        selected: i == _page,
        child: Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i == _page ? AppColors.primary : const Color(0xFFD3E8C3),
          ),
        ),
      ),
    ),
  );
}

class _ArtClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..lineTo(0, s.height - 24)
    ..quadraticBezierTo(s.width / 2, s.height + 24, s.width, s.height - 24)
    ..lineTo(s.width, 0)
    ..close();
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

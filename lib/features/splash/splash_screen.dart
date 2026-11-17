import 'dart:async';
import 'package:material_ui/material_ui.dart';
import '../../routes/app_routes.dart';
import '../../shared/widgets/ploggr_ui.dart';
import '../../shared/widgets/eco_art.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) switchPage(context, AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        const Positioned(
          top: -32,
          left: -12,
          child: RotatedBox(
            quarterTurns: 1,
            child: LeafSprig(width: 155, height: 170),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Image.asset(
            'assets/images/illustrations/splash.png',
            height: MediaQuery.sizeOf(context).height * .55,
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
            excludeFromSemantics: true,
          ),
        ),
        SafeArea(
          child: Align(
            alignment: const Alignment(0, -.25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const PloggrLogo(size: 82),
                const SizedBox(height: 20),
                Text(
                  'Plog today.',
                  style: AppText.heading.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'Change tomorrow.',
                  style: AppText.heading.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

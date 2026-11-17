import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:ploggr/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const String _logoAssetPath = "assets/images/splash_logo/image.png";

  Timer? _timer;
  bool _didPrecacheLogo = false;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      context.go(AppRoutes.login);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didPrecacheLogo) return;
    _didPrecacheLogo = true;
    precacheImage(const AssetImage(_logoAssetPath), context).catchError((_) {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.asset(_logoAssetPath)));
  }
}

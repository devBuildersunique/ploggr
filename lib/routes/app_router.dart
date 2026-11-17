import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ploggr/routes/app_routes.dart';
import 'package:ploggr/features/auth/login_page.dart';
import 'package:ploggr/features/auth/signup_page.dart';
import 'package:ploggr/features/home/end_session.dart';
import 'package:ploggr/features/home/home_page.dart';
import 'package:ploggr/features/home/in_session.dart';
import 'package:ploggr/features/leaderboard/leaderboard_page.dart';
import 'package:ploggr/features/splash/splash_screen.dart';

/// App-wide router. Feature routes can be registered here as the app grows.
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            );

            return FadeTransition(opacity: curvedAnimation, child: child);
          },
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        builder: (context, state) => const LeaderboardPage(),
      ),
      GoRoute(
        path: AppRoutes.session,
        builder: (context, state) => const InSessionPage(),
      ),
      GoRoute(
        path: AppRoutes.sessionSummary,
        builder: (context, state) => const EndSessionPage(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

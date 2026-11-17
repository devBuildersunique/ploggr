/// URL paths for the app's top-level screens.
///
/// Keeping paths together makes it easier to add routes without scattering
/// string literals across feature widgets.
abstract final class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const leaderboard = '/leaderboard';
  static const session = '/session';
  static const sessionSummary = '/session/summary';
}

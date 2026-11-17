// Optional deterministic render capture for visual review without an emulator.
// Run: flutter test tool/render_preview_test.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ploggr/app.dart';
import 'package:ploggr/routes/app_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture visual previews', (tester) async {
    final font = FontLoader('NunitoSans')
      ..addFont(rootBundle.load('assets/fonts/NunitoSans.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    final container = ProviderContainer();
    final key = GlobalKey();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(key: key, child: const PloggrApp()),
      ),
    );
    await tester.runAsync(() async {
      for (final asset in [
        'assets/images/illustrations/splash.png',
        'assets/images/illustrations/plogging.png',
        'assets/images/illustrations/together.png',
        'assets/images/demo/litter.png',
      ]) {
        await precacheImage(
          AssetImage(asset),
          tester.element(find.byType(PloggrApp)),
        );
      }
    });
    await tester.pump();
    final routes = [
      '/',
      '/onboarding',
      '/onboarding?page=1',
      '/onboarding?page=2',
      '/login',
      '/signup',
      '/home',
      '/scan',
      '/report',
      '/map',
      '/session',
      '/session/summary',
      '/cleanups',
      '/challenges',
      '/leaderboard',
      '/badges',
      '/community',
      '/profile',
    ];
    for (var i = 0; i < routes.length; i++) {
      if (i != 0) {
        container.read(appRouterProvider).go('/home');
        await tester.pumpAndSettle();
        container.read(appRouterProvider).go(routes[i]);
        await tester.pumpAndSettle();
      } else {
        await tester.pump();
      }
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 1.5);
        final bytes = (await image.toByteData(
          format: ui.ImageByteFormat.png,
        ))!.buffer.asUint8List();
        final file = File(
          'build/visual-previews/${(i + 1).toString().padLeft(2, '0')}.png',
        );
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes);
        image.dispose();
      });
    }
    await tester.pumpWidget(const SizedBox.shrink());
    container.dispose();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

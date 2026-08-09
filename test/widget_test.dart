import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ploggr/main.dart';
import 'package:ploggr/features/splash/splash_screen.dart';

class _TestAssetBundle extends AssetBundle {
  static final Uint8List _transparentPng = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO2Y7WQAAAAASUVORK5CYII=',
  );
  static final ByteData _emptyAssetManifest = const StandardMessageCodec()
      .encodeMessage(<String, List<String>>{})!;

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return _emptyAssetManifest;
    }

    return ByteData.view(_transparentPng.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    throw UnimplementedError();
  }
}

void main() {
  testWidgets('shows splash then navigates to login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      DefaultAssetBundle(bundle: _TestAssetBundle(), child: const PloggrApp()),
    );
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}

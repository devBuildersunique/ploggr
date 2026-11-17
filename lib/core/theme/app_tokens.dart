import 'package:material_ui/material_ui.dart';
import '../constants/app_colors.dart';

abstract final class AppSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const page = EdgeInsets.symmetric(horizontal: 20);
}

abstract final class AppRadius {
  static const small = BorderRadius.all(Radius.circular(12));
  static const card = BorderRadius.all(Radius.circular(16));
  static const pill = BorderRadius.all(Radius.circular(100));
}

abstract final class AppShadows {
  static const soft = [
    BoxShadow(color: Color(0x09103F20), blurRadius: 12, offset: Offset(0, 3)),
  ];
}

abstract final class AppText {
  static const hero = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -1.2,
  );
  static const title = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    height: 1.25,
    letterSpacing: -.6,
  );
  static const heading = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w800,
    height: 1.3,
    letterSpacing: -.3,
  );
  static const body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );
  static const label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1.3,
  );
  static const caption = TextStyle(
    fontSize: 13,
    color: AppColors.muted,
    height: 1.4,
  );
}

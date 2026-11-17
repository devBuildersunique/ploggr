import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = NotifierProvider<ProfileController, String>(
  ProfileController.new,
);

class ProfileController extends Notifier<String> {
  @override
  String build() => 'Vipul Reddy';
  void rename(String name) {
    if (name.trim().isNotEmpty) state = name.trim();
  }
}

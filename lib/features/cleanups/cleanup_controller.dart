import 'package:flutter_riverpod/flutter_riverpod.dart';

final joinedCleanupsProvider =
    NotifierProvider<JoinedCleanupsController, Set<String>>(
      JoinedCleanupsController.new,
    );

class JoinedCleanupsController extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  void toggle(String id) =>
      state = state.contains(id) ? ({...state}..remove(id)) : {...state, id};
}

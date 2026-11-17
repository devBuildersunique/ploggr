import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/preview/preview_data.dart';

final sessionProvider = NotifierProvider<SessionController, SessionState>(
  SessionController.new,
);
final impactProvider = NotifierProvider<ImpactController, ImpactState>(
  ImpactController.new,
);

class SessionState {
  const SessionState({
    this.seconds = 1456,
    this.active = false,
    this.paused = false,
    this.saved = false,
    this.kg = 2.5,
    this.litterType = 'Plastic',
    this.photos = 3,
  });
  final int seconds, photos;
  final bool active, paused, saved;
  final double kg;
  final String litterType;
  String get elapsed =>
      '${(seconds ~/ 3600).toString().padLeft(2, '0')}:${(seconds ~/ 60 % 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  SessionState copyWith({
    int? seconds,
    int? photos,
    bool? active,
    bool? paused,
    bool? saved,
    double? kg,
    String? litterType,
  }) => SessionState(
    seconds: seconds ?? this.seconds,
    photos: photos ?? this.photos,
    active: active ?? this.active,
    paused: paused ?? this.paused,
    saved: saved ?? this.saved,
    kg: kg ?? this.kg,
    litterType: litterType ?? this.litterType,
  );
}

class SessionController extends Notifier<SessionState> {
  Timer? _timer;
  @override
  SessionState build() {
    ref.onDispose(() => _timer?.cancel());
    return const SessionState();
  }

  void start() {
    state = const SessionState(active: true);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.active && !state.paused) {
        state = state.copyWith(seconds: state.seconds + 1);
      }
    });
  }

  void togglePause() {
    if (state.saved) return;
    if (!state.active) {
      // Returning from the unsaved summary resumes the same draft session.
      state = state.copyWith(active: true, paused: false);
      _startTimer();
    } else {
      state = state.copyWith(paused: !state.paused);
    }
  }

  void finish() {
    _timer?.cancel();
    state = state.copyWith(active: false, paused: true);
  }

  void setWeight(double value) =>
      state = state.copyWith(kg: (value * 10).round().clamp(0, 999) / 10);
  void selectType(String type) => state = state.copyWith(litterType: type);
  void addPhoto() {
    if (state.photos < 6) state = state.copyWith(photos: state.photos + 1);
  }

  void removePhoto() {
    if (state.photos > 0) state = state.copyWith(photos: state.photos - 1);
  }

  bool save() {
    if (state.saved) return false;
    finish();
    ref.read(impactProvider.notifier).addSession(state);
    state = state.copyWith(saved: true);
    return true;
  }
}

class ImpactState {
  const ImpactState({
    this.kg = 12.4,
    this.sessions = 18,
    this.savedSessions = const [],
  });
  final double kg;
  final int sessions;
  final List<SavedSession> savedSessions;
}

class SavedSession {
  const SavedSession(this.date, this.kg, this.duration, this.litterType);
  final DateTime date;
  final double kg;
  final String duration, litterType;
}

class ImpactController extends Notifier<ImpactState> {
  @override
  ImpactState build() => const ImpactState();
  void addSession(SessionState session) => state = ImpactState(
    kg: state.kg + session.kg,
    sessions: state.sessions + 1,
    savedSessions: [
      SavedSession(
        PreviewData.sessionDate,
        session.kg,
        session.elapsed,
        session.litterType,
      ),
      ...state.savedSessions,
    ],
  );
}

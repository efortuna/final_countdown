import 'dart:async';

import 'package:final_countdown/data/persistence.dart';

/// Utility class that provides access to the time stream and also converts the
/// time stream separate streams of the individual digits.
/*
class FinalCountdown {
  FinalCountdown(
    this.duration, {
    Duration frequency = const Duration(seconds: 1),
    bool persist = true,
  }) : time = _countdown(
          duration,
          frequency: frequency,
          persist: persist,
        ).asBroadcastStream();
  final Stream<Duration> time;
  final Duration duration;

  Stream<Duration> get minuteStream =>
      time.where((Duration d) => d.inSeconds % 60 == 0);

  Stream<int> get tensMinuteDigit =>
      minuteStream.map<int>((Duration d) => d.inMinutes ~/ 10);
  Stream<int> get onesMinuteDigit =>
      minuteStream.map<int>((Duration d) => d.inMinutes % 10);
  Stream<int> get tensSecondDigit =>
      time.map<int>((Duration d) => (d.inSeconds % 60) ~/ 10);
  Stream<int> get onesSecondDigit =>
      time.map<int>((Duration d) => (d.inSeconds % 60) % 10);

  static Stream<Duration> _countdown(
    Duration duration, {
    Duration frequency = const Duration(seconds: 1),
    persist = true,
  }) async* {
    // Check the cache for a stored duration
    if (persist) duration = await loadDuration(duration);

    var remaining = duration;
    while (remaining >= const Duration()) {
      yield remaining;
      remaining -= frequency;
      await Future.delayed(frequency);
      // Save cache
      if (persist) saveDuration(remaining);
    }
    // Wipe the cache
    if (persist) deleteDuration();
  }
}
*/

class FinalCountdown2 {
  FinalCountdown2(
    this.duration, {
    this.frequency = const Duration(seconds: 1),
  });

  final Duration duration;
  final Duration frequency;

  Duration _remaining;
  Duration get remaining => _remaining;

  Stream<Duration> get stream async* {
    _remaining = duration;
    while (_remaining >= const Duration()) {
      yield _remaining;
      _remaining -= frequency;
      await Future.delayed(frequency);
    }
  }
}

class PersistedFinalCountdown {
  PersistedFinalCountdown(
    Duration startingDuration, {
    Duration frequency = const Duration(seconds: 1),
  }) {
    _controller = StreamController<Duration>();
    _init(startingDuration, frequency);
  }

  _init(Duration startingDuration, Duration frequency) async {
    final duration = await loadDuration(startingDuration);
    _countdown = FinalCountdown2(duration, frequency: frequency);
    await _controller.addStream(_countdown.stream);
    // Persist the countdown and delete the cache when done
    stream.listen((d) => print('HELLO'));
    stream.listen(saveDuration, onDone: deleteDuration);
  }

  StreamController<Duration> _controller;
  FinalCountdown2 _countdown;

  Stream<Duration> get stream => _controller.stream.asBroadcastStream();
  Duration get duration => _countdown.duration;
  Duration get remaining => _countdown.remaining;

  dispose() {
    _controller?.close();
  }
}

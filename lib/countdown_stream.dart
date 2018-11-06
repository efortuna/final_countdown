import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:final_countdown/countdown_persistence.dart';

/// Utility class that provides access to the time stream and also converts the
/// time stream separate streams of the individual digits.
class FinalCountdown {
  FinalCountdown(this.duration,
      {Duration frequency = const Duration(seconds: 1)})
      : time = _countdown(duration, frequency: frequency).asBroadcastStream();
  final Stream<Duration> time;
  final Duration duration;

  Stream<int> get tensMinuteDigit =>
      time.map<int>((Duration d) => d.inMinutes ~/ 10);
  Stream<int> get onesMinuteDigit =>
      time.map<int>((Duration d) => d.inMinutes % 10);
  Stream<int> get tensSecondDigit =>
      time.map<int>((Duration d) => (d.inSeconds % 60) ~/ 10);
  Stream<int> get onesSecondDigit =>
      time.map<int>((Duration d) => (d.inSeconds % 60) % 10);

  static Stream<Duration> _countdown(Duration duration,
      {Duration frequency = const Duration(seconds: 1)}) async* {
    // Check the cache for a stored duration
    duration = await loadDuration(duration);

    var remaining = duration;
    while (remaining > const Duration()) {
      remaining -= frequency;
      yield remaining;
      await Future.delayed(frequency);
      // Save cache
      saveDuration(remaining);
    }
    // Wipe the cache
    deleteDuration();
  }
}

/// Holds the countdown state
class CountdownTimer {
  CountdownTimer(this.duration, {this.frequency = const Duration(seconds: 1)});
  final Duration duration, frequency;
  Stream<Duration> stream;

  Stream<Duration> get countdown => stream ?? resetCountDown;

  Stream<Duration> get resetCountDown {
    stream = FinalCountdown(duration, frequency: frequency).time;
    return stream;
  }
}

/// Use to maintain state between hot reloads
/// Make sure you wrap this above the MaterialApp widget
/// or hot reload will affect it
class CountdownProvider extends InheritedWidget {
  CountdownProvider({
    Key key,
    Widget child,
    this.duration,
    this.frequency = const Duration(seconds: 1),
  })  : assert(child != null),
        assert(duration != null),
        countdownTimer = CountdownTimer(duration, frequency: frequency),
        super(key: key, child: child);

  final Duration duration, frequency;
  final CountdownTimer countdownTimer;

  Stream<Duration> get countdown => countdownTimer.countdown;

  static CountdownProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(CountdownProvider);

  @override
  bool updateShouldNotify(InheritedWidget _) => false;
}

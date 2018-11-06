import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

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

/// Use to maintain state between hot reloads
/// Make sure you wrap this above the MaterialApp widget
/// or hot reload will affect it
class CountdownProvider extends InheritedWidget {
  CountdownProvider({
    Key key,
    @required Widget child,
    @required this.duration,
    this.frequency = const Duration(seconds: 1),
  })  : assert(child != null),
        assert(duration != null),
        countdown = FinalCountdown(duration, frequency: frequency),
        super(key: key, child: child) {
    _subject.addStream(countdown.time);
    _tensMinuteDigitSubject.addStream(countdown.tensMinuteDigit);
    _onesMinuteDigitSubject.addStream(countdown.onesMinuteDigit);
    _tensSecondDigitSubject.addStream(countdown.tensSecondDigit);
    _onesSecondDigitSubject.addStream(countdown.onesSecondDigit);
  }

  final Duration duration, frequency;
  final FinalCountdown countdown;

  final _subject = BehaviorSubject<Duration>();
  final _tensMinuteDigitSubject = BehaviorSubject<int>();
  final _onesMinuteDigitSubject = BehaviorSubject<int>();
  final _tensSecondDigitSubject = BehaviorSubject<int>();
  final _onesSecondDigitSubject = BehaviorSubject<int>();

  get stream => _subject.stream;

  get tensMinuteDigitStream => _tensMinuteDigitSubject.stream;
  get onesMinuteDigitStream => _onesMinuteDigitSubject.stream;
  get tensSecondDigitStream => _tensSecondDigitSubject.stream;
  get onesSecondDigitStream => _onesSecondDigitSubject.stream;

  get tensMinuteDigit => _tensMinuteDigitSubject.value;
  get onesMinuteDigit => _onesMinuteDigitSubject.value;
  get tensSecondDigit => _tensSecondDigitSubject.value;
  get onesSecondDigit => _tensSecondDigitSubject.value;

  static CountdownProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(CountdownProvider);

  @override
  bool updateShouldNotify(InheritedWidget _) => false;
}

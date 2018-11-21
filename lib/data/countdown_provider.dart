import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'package:final_countdown/data/countdown_stream.dart';

/// Use to maintain state between hot restarts
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
        countdown = PersistedFinalCountdown(duration, frequency: frequency),
        super(key: key, child: child) {
    _subject.addStream(countdown.stream);

    /*
    _minuteSubject.addStream(
        countdown.stream.where((Duration d) => d.inSeconds % 60 == 0));
    _tensMinuteDigitSubject
        .addStream(countdown.stream.map<int>((d) => d.inMinutes ~/ 10));
    _onesMinuteDigitSubject
        .addStream(countdown.stream.map<int>((Duration d) => d.inMinutes % 10));
    _tensSecondDigitSubject.addStream(
        countdown.stream.map<int>((Duration d) => (d.inSeconds % 60) ~/ 10));
    _onesSecondDigitSubject.addStream(
        countdown.stream.map<int>((Duration d) => (d.inSeconds % 60) % 10));
    */
  }

  final Duration duration, frequency;
  final PersistedFinalCountdown countdown;

  final _subject = BehaviorSubject<Duration>();
  final _minuteSubject = BehaviorSubject<Duration>();
  final _tensMinuteDigitSubject = BehaviorSubject<int>();
  final _onesMinuteDigitSubject = BehaviorSubject<int>();
  final _tensSecondDigitSubject = BehaviorSubject<int>();
  final _onesSecondDigitSubject = BehaviorSubject<int>();

  Stream<Duration> get stream => _subject.stream;
  Duration get remaining => _subject.value;

  Stream<Duration> get minuteStream => _minuteSubject.stream;

  Stream<int> get tensMinuteDigitStream => _tensMinuteDigitSubject.stream;
  Stream<int> get onesMinuteDigitStream => _onesMinuteDigitSubject.stream;
  Stream<int> get tensSecondDigitStream => _tensSecondDigitSubject.stream;
  Stream<int> get onesSecondDigitStream => _onesSecondDigitSubject.stream;

  int get tensMinuteDigit => _tensMinuteDigitSubject.value;
  int get onesMinuteDigit => _onesMinuteDigitSubject.value;
  int get tensSecondDigit => _tensSecondDigitSubject.value;
  int get onesSecondDigit => _tensSecondDigitSubject.value;

  static CountdownProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(CountdownProvider);

  @override
  bool updateShouldNotify(InheritedWidget _) => false;
}

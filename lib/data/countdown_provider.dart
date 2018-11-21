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
    bool persist = true,
  })  : assert(child != null),
        assert(duration != null),
        countdown = FinalCountdown(
          duration,
          frequency: frequency,
          persist: persist,
        ),
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

  Stream<Duration> get stream => _subject.stream;
  Stream<Duration> get minuteStream => countdown.minuteStream;
  Duration get mostRecentTime => _subject.value;

  Stream<int> get tensMinuteDigitStream => _tensMinuteDigitSubject.stream;
  Stream<int> get onesMinuteDigitStream => _onesMinuteDigitSubject.stream;
  Stream<int> get tensSecondDigitStream => _tensSecondDigitSubject.stream;
  Stream<int> get onesSecondDigitStream => _onesSecondDigitSubject.stream;

  get tensMinuteDigit => _tensMinuteDigitSubject.value;
  get onesMinuteDigit => _onesMinuteDigitSubject.value;
  get tensSecondDigit => _tensSecondDigitSubject.value;
  get onesSecondDigit => _tensSecondDigitSubject.value;

  static CountdownProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(CountdownProvider);

  @override
  bool updateShouldNotify(InheritedWidget _) => false;
}

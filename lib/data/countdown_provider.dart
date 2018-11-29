import 'package:flutter/widgets.dart';
import 'package:rxdart/rxdart.dart';

import 'package:final_countdown/data/countdown_stream.dart';

/// Implements the logic for countdown streams
class Countdown {
  Countdown({
    @required this.duration,
    this.frequency = const Duration(seconds: 1),
  })  : assert(duration != null),
        _countdown = PersistedFinalCountdown(duration, frequency: frequency) {
    _countdown.stream.pipe(_subject);

    _minuteSubject.addStream(
        _countdown.stream.where((Duration d) => d.inSeconds % 60 == 0));
    _tensMinuteDigitSubject
        .addStream(_countdown.stream.map<int>((d) => d.inMinutes ~/ 10));
    _onesMinuteDigitSubject
        .addStream(_countdown.stream.map<int>((d) => d.inMinutes % 10));
    _tensSecondDigitSubject
        .addStream(_countdown.stream.map<int>((d) => (d.inSeconds % 60) ~/ 10));
    _onesSecondDigitSubject
        .addStream(_countdown.stream.map<int>((d) => (d.inSeconds % 60) % 10));
  }

  final Duration duration, frequency;
  final PersistedFinalCountdown _countdown;

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

  int get tensMinuteDigit => _tensMinuteDigitSubject.value ?? 0;
  int get onesMinuteDigit => _onesMinuteDigitSubject.value ?? 0;
  int get tensSecondDigit => _tensSecondDigitSubject.value ?? 0;
  int get onesSecondDigit => _tensSecondDigitSubject.value ?? 0;

  void start() => _countdown.start();

  void dispose() {
    _countdown?.dispose();
    _subject?.close();
    _minuteSubject?.close();
    _tensMinuteDigitSubject?.close();
    _onesMinuteDigitSubject?.close();
    _tensSecondDigitSubject?.close();
    _onesSecondDigitSubject?.close();
  }
}

/// Wrapping the countdown timers in a StatefulWidget so that
/// timers an streams are disposed of properly
class CountdownProviderModel extends StatefulWidget {
  CountdownProviderModel({
    this.child,
    this.duration,
    this.frequency = const Duration(seconds: 1),
  });
  final Widget child;
  final Duration duration;
  final Duration frequency;

  @override
  createState() => _CountdownProviderModelState();
}

class _CountdownProviderModelState extends State<CountdownProviderModel> {
  Countdown _countdown;

  @override
  void initState() {
    _countdown =
        Countdown(duration: widget.duration, frequency: widget.frequency);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CountdownProvider(countdown: _countdown, child: widget.child);
  }

  @override
  void dispose() {
    _countdown?.dispose();
    super.dispose();
  }
}

/// Used to access the countdown streams in the widget tree
class CountdownProvider extends InheritedWidget {
  final Countdown countdown;
  CountdownProvider({this.countdown, Widget child})
      : assert(countdown != null),
        assert(child != null),
        super(child: child);

  static Countdown of(BuildContext context) =>
      (context.inheritFromWidgetOfExactType(CountdownProvider)
              as CountdownProvider)
          .countdown;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return oldWidget != this;
  }
}

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:final_countdown/matt/utils.dart';

Stream<Duration> _countdown(Duration duration,
    {Duration frequency = const Duration(seconds: 1)}) async* {
  var remaining = duration;
  while (remaining > const Duration()) {
    remaining -= const Duration(seconds: 1);
    yield remaining;
    await Future.delayed(frequency);
  }
}

/// Holds the countdown state
class CountdownTimer {
  CountdownTimer(this.duration, {this.frequency = const Duration(seconds: 1)});
  final Duration duration, frequency;
  Stream<Duration> stream;

  Stream<Duration> get countdown => stream ?? resetCountDown;

  Stream<Duration> get resetCountDown {
    stream = _countdown(duration, frequency: frequency);
    return stream;
  }
}

/// Use to maintain state between hot reloads
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

class Countdown extends StatelessWidget {
  Countdown({this.duration});
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return CountdownProvider(
      duration: const Duration(minutes: 15),
      child: Center(
        child: Builder(
          builder: (context) => StreamBuilder(
                stream: CountdownProvider.of(context)
                    .countdown, //_countdown(const Duration(minutes: 15)),
                builder: (context, AsyncSnapshot<Duration> snapshot) {
                  if (snapshot.hasData)
                    return Text('Time ${prettyPrintDuration(snapshot.data)}');
                  else
                    return Text('Waiting ...');
                },
              ),
        ),
      ),
    );
  }
}

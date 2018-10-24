import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:final_countdown/matt/utils.dart';

Stream<Duration> _countdown(Duration duration,
    {Duration frequency = const Duration(seconds: 1)}) async* {
  var remaining = duration;
  while (remaining > const Duration()) {
    remaining -= frequency;
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

class Countdown extends StatelessWidget {
  Countdown({this.duration});
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Builder(
        builder: (context) => StreamBuilder(
              stream: _countdown(const Duration(
                  minutes: 1)), //CountdownProvider.of(context).countdown,
              builder: (context, AsyncSnapshot<Duration> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text('Waiting ...');
                  case ConnectionState.active:
                    return Text('Time ${prettyPrintDuration(snapshot.data)}');
                  case ConnectionState.done:
                    return Text('Time\s up!');
                  case ConnectionState.none:
                    return Text(
                        'Entered oblivion; this should never have happened');
                }
              },
            ),
      ),
    );
  }
}

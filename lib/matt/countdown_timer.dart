import 'dart:async';

import 'package:flutter/material.dart';

class Countdown extends StatefulWidget {
  Countdown({this.duration});
  final Duration duration;

  @override
  createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  Duration remaining;

  @override
  initState() {
    super.initState();
    remaining = widget.duration;

    const interval = Duration(seconds: 1);
    Timer.periodic(interval, (t) {
      setState(() => remaining -= interval);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_prettyPrintDuration(remaining));
  }
}

/// Returns a human-readable representation of a duration
String _prettyPrintDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  final minutesStr = minutes >= 10 ? '$minutes' : '0$minutes';
  final secondsStr = seconds >= 10 ? '$seconds' : '0$seconds';

  return '$minutesStr:$secondsStr';
}

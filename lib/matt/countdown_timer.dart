import 'dart:async';

import 'package:flutter/material.dart';

import 'package:final_countdown/utils.dart';

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
    return Text(prettyPrintDuration(remaining));
  }
}

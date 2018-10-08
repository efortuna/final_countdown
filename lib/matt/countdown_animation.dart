import 'package:flutter/material.dart';

import 'package:final_countdown/matt/utils.dart';

class Countdown extends StatefulWidget {
  Countdown({this.duration});
  final Duration duration;

  @override
  createState() => _CountdownState();
}

class _CountdownState extends State<Countdown>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  initState() {
    super.initState();
    final upperBound = widget.duration.inSeconds.toDouble();
    _controller = AnimationController(
        duration: widget.duration,
        lowerBound: 0.0,
        upperBound: upperBound,
        vsync: this)
      ..reverse(from: upperBound);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Text(prettyPrintDuration(
            Duration(seconds: _controller.value.floor()),
          )),
    );
  }
}

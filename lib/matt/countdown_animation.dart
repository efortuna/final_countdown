import 'package:flutter/material.dart';

import 'package:fx/fx.dart';

import 'package:final_countdown/matt/text_duration.dart';
import 'package:final_countdown/matt/flipper.dart';

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
        builder: (context, _) {
          final text = TextDuration(
              duration: Duration(
            seconds: _controller.value.floor(),
          ));

          // return Wavy(duration: const Duration(seconds: 1), child: text);
          return Flipper(front: text, back: text);
        });
  }
}

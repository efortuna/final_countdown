// https://stackoverflow.com/questions/44990714/flutter-effect-of-flip-card

import 'package:flutter/material.dart';

class Flipper extends StatefulWidget {
  Flipper({
    this.front,
    this.back,
    this.duration = const Duration(seconds: 1),
  });
  final Widget front;
  final Widget back;
  final Duration duration;

  createState() => _FlipperState();
}

class _FlipperState extends State<Flipper> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _frontScale;
  Animation<double> _backScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _frontScale = Tween(begin: 1.0, end: 0.0).animate(CurvedAnimation(
        parent: _controller, curve: Interval(0.0, 0.5, curve: Curves.easeIn)));
    _backScale = CurvedAnimation(
        parent: _controller, curve: Interval(0.5, 1.0, curve: Curves.easeOut));
    _controller.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _controller.reverse();
      } else if (s == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AnimatedBuilder(
          child: widget.front,
          animation: _backScale,
          builder: (BuildContext context, Widget child) {
            final Matrix4 transform = Matrix4.identity()
              ..scale(1.0, _backScale.value, 1.0);
            return Transform(
              transform: transform,
              alignment: FractionalOffset.center,
              child: child,
            );
          },
        ),
        AnimatedBuilder(
          child: widget.back,
          animation: _frontScale,
          builder: (BuildContext context, Widget child) {
            final Matrix4 transform = Matrix4.identity()
              ..scale(1.0, _frontScale.value, 1.0);
            return Transform(
              transform: transform,
              alignment: FractionalOffset.center,
              child: child,
            );
          },
        ),
      ],
    );
  }
}

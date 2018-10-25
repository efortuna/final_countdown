import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class Countdown extends StatelessWidget {
  Countdown({this.duration});
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    var frostedGlass = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
        child: Container(
            width: 200.0,
            height: 500.0,
            decoration:
                BoxDecoration(color: Colors.grey.shade200.withOpacity(0.1))));

    return Container(
      color: Colors.brown,
      child: Column(
        children: <Widget>[
          Container(
              foregroundDecoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/wood_planks.jpg'),
                      fit: BoxFit.cover)),
              height: 100.0),
          Text('clock goes here'),
          Stack(
            children: <Widget>[
              Stack(
                children: [
                  Stack(
                    children: <Widget>[
                      Image.asset('assets/wood.jpg',
                          height: 500.0, width: 410.0, fit: BoxFit.cover),
                      Pendulum(),
                    ],
                    alignment: Alignment.topCenter,
                  ),
                  ClipPath(
                    child: frostedGlass,
                    clipper: RightCurve(),
                  ),
                ],
                alignment: Alignment.topRight,
              ),
              FrostedLeftClip(frostedGlass),
            ],
          ),
        ],
      ),
    );
  }
}

class FrostedLeftClip extends StatelessWidget {
  final Widget theChild;
  FrostedLeftClip(this.theChild);

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      child: theChild,
      clipper: LeftCurve(),
    );
  }
}

class Pendulum extends StatefulWidget {
  @override
  _PendulumState createState() => _PendulumState();
}

class _PendulumState extends State<Pendulum> with TickerProviderStateMixin {
  AnimationController _animationController;

  @override
  initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      lowerBound: -.03,
      upperBound: .03,
      vsync: this,
    )..forward();
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PivotTransition(
        turns: _animationController,
        child: Container(color: Colors.black, width: 20.0, height: 400.0));
  }
}

/// Animates the rotation of a widget around a pivot point.
class PivotTransition extends AnimatedWidget {
  /// Creates a rotation transition.
  ///
  /// The [turns] argument must not be null.
  PivotTransition({
    Key key,
    this.alignment: FractionalOffset.topCenter,
    @required Animation<double> turns,
    this.child,
  }) : super(key: key, listenable: turns);

  /// The animation that controls the rotation of the child.
  ///
  /// If the current value of the turns animation is v, the child will be
  /// rotated v * 2 * pi radians before being painted.
  Animation<double> get turns => listenable;

  /// The pivot point to rotate around.
  final FractionalOffset alignment;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double turnsValue = turns.value;
    final Matrix4 transform = new Matrix4.rotationZ(turnsValue * math.pi * 2.0);
    return new Transform(
      transform: transform,
      alignment: alignment,
      child: child,
    );
  }
}

class LeftCurve extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0.0, size.height)
      ..lineTo(size.width / 2.0, size.height)
      ..quadraticBezierTo(size.width - size.width / 3.0, size.height / 2.0,
          size.width / 2.0, 0.0);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class RightCurve extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(size.width, 0.0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2.0, size.height)
      ..quadraticBezierTo(
          size.width / 3.0, size.height / 2.0, size.width / 2.0, 0.0);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

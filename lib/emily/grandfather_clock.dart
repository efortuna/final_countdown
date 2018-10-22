import 'package:flutter/material.dart';
import 'dart:ui';

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
                  Image.asset('assets/wood.jpg', height: 500.0, width: 410.0, fit: BoxFit.cover),
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

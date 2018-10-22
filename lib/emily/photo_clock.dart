// Inspired by: https://medium.com/flutter-community/make-3d-flip-animation-in-flutter-16c006bb3798
import 'package:flutter/material.dart';
import 'package:flip_panel/flip_panel.dart';

class Countdown extends StatelessWidget {
  Countdown({this.duration});
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    var chrome = Image.asset(
      'assets/brushed_metal.jpg',
      height: 100.0,
      width: 500.0,
      repeat: ImageRepeat.repeatX,
    );
    return Container(
      color: Colors.grey[400],
      child: Column(
        children: <Widget>[
          chrome,
          Expanded(
            child: FlipClock.countdown(
              duration: duration,
              digitColor: Colors.white,
              backgroundColor: Colors.black,
              digitSize: 48.0,
              borderRadius: const BorderRadius.all(Radius.circular(3.0)),
              onDone: () => print("Time's up!"),
              flipDirection: FlipDirection.down,
            ),
          ),
          chrome,
        ],
      ),
    );
  }
}

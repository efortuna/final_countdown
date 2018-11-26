// Inspired by: https://medium.com/flutter-community/make-3d-flip-animation-in-flutter-16c006bb3798
import 'package:flutter/material.dart';

import 'package:final_countdown/data/countdown_provider.dart';
import 'package:final_countdown/styling.dart';

class RetroClock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Positioned.fill(
          child: Image.asset('assets/wood.jpg', fit: BoxFit.cover),
        ),
        ClockFrame(),
      ],
    );
  }
}

class ClockFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white, width: 10),
          borderRadius: BorderRadius.circular(20)),
      color: Colors.grey[800],
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FittedBox(child: ClockFace()),
      ),
    );
  }
}

class ClockFace extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final countdown = CountdownProvider.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(children: <Widget>[
        FlipDigit(
            stream: countdown.tensMinuteDigitStream,
            initial: countdown.tensMinuteDigit),
        SizedBox(width: 10),
        FlipDigit(
            stream: countdown.onesMinuteDigitStream,
            initial: countdown.onesMinuteDigit),
        SizedBox(width: 10),
        FlipBox(':'),
        SizedBox(width: 10),
        FlipDigit(
            stream: countdown.tensSecondDigitStream,
            initial: countdown.tensSecondDigit),
        SizedBox(width: 10),
        FlipDigit(
            stream: countdown.onesSecondDigitStream,
            initial: countdown.onesSecondDigit),
      ]),
    );
  }
}

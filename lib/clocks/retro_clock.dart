// Inspired by: https://medium.com/flutter-community/make-3d-flip-animation-in-flutter-16c006bb3798
import 'package:flutter/material.dart';
import 'package:flip_panel/flip_panel.dart';
import 'package:final_countdown/data/countdown_provider.dart';

class RetroClock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Positioned.fill(
          child: Image.asset(
            'assets/wood.jpg',
            fit: BoxFit.cover,
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.white, width: 10.0),
              borderRadius: BorderRadius.circular(20)),
          color: Colors.grey[800],
          elevation: 4,
          child: FittedBox(child: ClockPanel()),
        ),
      ],
    );
  }
}

class ClockPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final countdown = CountdownProvider.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
          // TODO: On large screens, like iPads, this looks bad so spaced out.
          // We need a different layout option.
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            StreamFlipDigit(countdown.tensMinuteDigitStream),
            SizedBox(width: 5),
            StreamFlipDigit(countdown.onesMinuteDigitStream),
            SizedBox(width: 5),
            FlipBox(':'),
            SizedBox(width: 5),
            StreamFlipDigit(countdown.tensSecondDigitStream),
            SizedBox(width: 5),
            StreamFlipDigit(countdown.onesSecondDigitStream),
          ]),
    );
  }
}

class StreamFlipDigit extends StatelessWidget {
  StreamFlipDigit(this.digitStream);
  final Stream<int> digitStream;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlipPanel<int>.stream(
          itemStream: digitStream,
          direction: FlipDirection.down,
          itemBuilder: (context, digit) {
            return FlipBox('$digit');
          }),
    );
  }
}

class FlipBox extends StatelessWidget {
  FlipBox(this.str);
  final String str;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 40,
          height: 60,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(str,
                style: TextStyle(
                    // fontFamily: 'Orbitron',
                    fontWeight: FontWeight.bold,
                    fontSize: 60,
                    color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

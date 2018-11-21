// Inspired by: https://medium.com/flutter-community/make-3d-flip-animation-in-flutter-16c006bb3798
import 'package:flutter/material.dart';
import 'package:flip_panel/flip_panel.dart';
import 'package:final_countdown/data/countdown_provider.dart';

final _digitTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 60,
  color: Colors.white,
);

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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FittedBox(child: ClockPanel()),
          ),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
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

class FlipBox extends StatelessWidget {
  FlipBox(this.str);
  final String str;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints.tight(Size(120, 180)),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        child: Text(str, style: _digitTextStyle),
      ),
    );
  }
}

class FlipDigit extends StatelessWidget {
  FlipDigit({@required this.stream, this.initial = 0});
  final Stream<int> stream;
  final int initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlipPanel<int>.stream(
          itemStream: stream,
          initValue: initial,
          direction: FlipDirection.down,
          itemBuilder: (_, digit) {
            return FlipBox('$digit');
          }),
    );
  }
}

/*
class FlipTextTheme extends StatelessWidget {
  FlipTextTheme({this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(textTheme: Theme.of(context).textTheme.body1.copyWith(
        fontWeight: FontWeight.bold,
  fontSize: 60,
  color: Colors.white,)),
      child: child,
    );
  }
}
*/

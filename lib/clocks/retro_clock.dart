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
          child: Image.asset('assets/wood.jpg', fit: BoxFit.cover),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 200.0, horizontal: 10.0),
          child: Card(
            shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white, width: 10.0),
                borderRadius: BorderRadius.circular(20)),
            color: Colors.grey[800],
            elevation: 4,
            child: ClockPanel(),
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
            StreamFlipDigit(countdown.tensMinuteDigitStream),
            StreamFlipDigit(countdown.onesMinuteDigitStream),
            //SizedBox(width: 50),
            FlipBox(':'),
            StreamFlipDigit(countdown.onesMinuteDigitStream),
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
          initValue: 7, // TODO: Matt -- Is this intentional?
          direction: FlipDirection.down,
          itemBuilder: (context, digit) {
            return FlipBox(digit.toString());
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
        child: SizedBox(
          width: 40,
          height: 50,
          child: FittedBox(
            fit: BoxFit.contain,
            child: Text(
              str,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 60,
                  // TODO: Consider setting font too. This one could be cool: 
                  // https://fonts.google.com/specimen/Wallpoet
                  color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class StreamFlipClock extends StatelessWidget {
  final _spacing = const EdgeInsets.symmetric(horizontal: 2);
  static final _digitSize = 90.0;
  static final _panelHeight = _digitSize + 20;
  static final _textStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: _digitSize, color: Colors.white);
  final _borderRadius = const BorderRadius.all(Radius.circular(3));

  Widget _buildDigit(Stream<int> streamSource, int startValue) {
    return Padding(
      padding: _spacing,
      child: FlipPanel<int>.stream(
        itemStream: streamSource,
        // TODO(efortuna): Get "startValue" from "preferences" somehow don't always show 15
        initValue: startValue,
        direction: FlipDirection.down,
        itemBuilder: (context, digit) => Container(
              alignment: Alignment.center,
              width: _digitSize - 20,
              height: _panelHeight,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: _borderRadius,
              ),
              child: Text(
                '$digit',
                style: _textStyle,
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final countdown = CountdownProvider.of(context);
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Minutes
          _buildDigit(
              countdown.tensMinuteDigitStream, countdown.tensMinuteDigit),
          _buildDigit(
              countdown.onesMinuteDigitStream, countdown.onesMinuteDigit),

          _buildSeparator(),

          // Seconds
          _buildDigit(
              countdown.tensSecondDigitStream, countdown.tensSecondDigit),
          _buildDigit(
              countdown.onesSecondDigitStream, countdown.onesSecondDigit),
        ],
      ),
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: _spacing,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: _borderRadius,
        ),
        width: _digitSize / 4,
        height: _panelHeight,
        alignment: Alignment.center,
        child: Text(
          ':',
          style: _textStyle,
        ),
      ),
    );
  }
}

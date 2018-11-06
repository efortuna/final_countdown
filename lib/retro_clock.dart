// Inspired by: https://medium.com/flutter-community/make-3d-flip-animation-in-flutter-16c006bb3798
import 'package:flutter/material.dart';
import 'package:flip_panel/flip_panel.dart';
import 'package:final_countdown/countdown_stream.dart';

class RetroClock extends StatelessWidget {
  RetroClock(this.time);
  final FinalCountdown time;

  @override
  Widget build(BuildContext context) {
    var wood = Image.asset('assets/wood.jpg',
        height: 100.0, width: 500.0, fit: BoxFit.cover);
    return Container(
      color: Colors.black,
      child: Column(
        children: <Widget>[
          wood,
          Expanded(
            child: Card(
              child: Card(
                color: Colors.grey[800],
                elevation: 4.0,
                margin: EdgeInsets.all(10.0),
                child: StreamFlipClock(time),
              ),
              elevation: 20.0,
            ),
          ),
          wood,
        ],
      ),
    );
  }
}

class StreamFlipClock extends StatelessWidget {
  StreamFlipClock(this.time);
  final FinalCountdown time;
  final _spacing = const EdgeInsets.symmetric(horizontal: 2.0);
  static final _digitSize = 96.0;
  static final _panelHeight = _digitSize + 20;
  static final _textStyle = TextStyle(
      fontWeight: FontWeight.bold, fontSize: _digitSize, color: Colors.white);
  final _borderRadius = const BorderRadius.all(Radius.circular(3.0));

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

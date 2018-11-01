// Inspired by: https://medium.com/flutter-community/make-3d-flip-animation-in-flutter-16c006bb3798
import 'package:flutter/material.dart';
import 'package:flip_panel/flip_panel.dart';
import 'package:final_countdown/countdown_stream.dart';

class Countdown extends StatelessWidget {
  Countdown({this.duration}) : time = FinalCountdown(duration);
  final Duration duration;
  final FinalCountdown time;

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
            child: StreamFlipClock(time),
            /*child: FlipClock.countdown(
              duration: duration,
              digitColor: Colors.white,
              backgroundColor: Colors.black,
              digitSize: 48.0,
              borderRadius: const BorderRadius.all(Radius.circular(3.0)),
              onDone: () => print("Time's up!"),
              flipDirection: FlipDirection.down,
            ),*/
          ),
          chrome,
        ],
      ),
    );

    /*_separator = Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      width: 24.0,
      height: 60.0,
      alignment: Alignment.center,
      child: Text(
        ':',
        style: TextStyle(
          fontSize: digitSize,
          color: digitColor,
        ),
      ),
    )
    */
  }
}

class StreamFlipClock extends StatelessWidget {
  StreamFlipClock(this.time);
  final FinalCountdown time;
  final _spacing = const EdgeInsets.symmetric(horizontal: 2.0);
  final _digitSize = 48.0;
  final _borderRadius = const BorderRadius.all(Radius.circular(3.0));

  Container _buildDigit(context, digit) => Container(
        alignment: Alignment.center,
        width: 44.0,
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: _borderRadius,
        ),
        child: Text(
          '$digit',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: _digitSize,
              color: Colors.white),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        // Minutes
        FlipPanel<int>.stream(
            itemStream: time.tensMinuteDigit,
            itemBuilder: _buildDigit,
            initValue: time.duration.inMinutes ~/ 10,
            direction: FlipDirection.down),
        FlipPanel<int>.stream(
            itemStream: time.onesMinuteDigit,
            itemBuilder: _buildDigit,
            initValue: time.duration.inMinutes % 10,
            direction: FlipDirection.down),

        _buildSeparator(),

        // Seconds
        FlipPanel<int>.stream(
            itemStream: time.tensSecondDigit,
            itemBuilder: _buildDigit,
            initValue: (time.duration.inSeconds % 60) ~/ 10,
            direction: FlipDirection.down),
        FlipPanel<int>.stream(
            itemStream: time.onesSecondDigit,
            itemBuilder: _buildDigit,
            initValue: (time.duration.inSeconds % 60) % 10,
            direction: FlipDirection.down),
      ],
    );
  }

  Container _buildSeparator() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: _borderRadius,
      ),
      width: 24.0,
      height: 60.0,
      alignment: Alignment.center,
      child: Text(
        ':',
        style: TextStyle(
          fontSize: _digitSize,
          color: Colors.white,
        ),
      ),
    );
  }
}

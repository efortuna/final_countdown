// Inspired by: https://medium.com/flutter-community/make-3d-flip-animation-in-flutter-16c006bb3798
import 'package:flutter/material.dart';
import 'package:flip_panel/flip_panel.dart';
import 'package:final_countdown/countdown_stream.dart';

class RetroClock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var wood = Image.asset('assets/wood.jpg',
        height: 200.0, width: 500.0, fit: BoxFit.cover);
    return Container(
      color: Colors.black,
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              wood,
              Container(
      width: 100.0,
      height: 100.0,
      child: new RawMaterialButton(
        fillColor: Colors.black,
        shape: CircleBorder(),
        elevation: 0.0,
        child: Text('hello'),
      onPressed: (){},
  ),),
              Padding(
                padding: const EdgeInsets.all(100.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  child: Text('press me'),
                  onPressed: () => print('hi'),
                  //elevation: 5.0,
                ),
              ),
            ],
          ),
          Expanded(
            child: Card(
              child: Card(
                color: Colors.grey[800],
                elevation: 4.0,
                margin: EdgeInsets.all(10.0),
                child: StreamFlipClock(),
              ),
              elevation: 20.0,
            ),
          ),
          Stack(
            children: <Widget>[
              wood,
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    child: Container(
                      color: Colors.transparent,
                      height: 150,
                      child: Column(
                        children: <Widget>[
                          Speaker(),
                          Speaker(),
                          Speaker(),
                          Speaker(),
                          Speaker(),
                          Speaker(),
                          Speaker(),
                          Speaker(),
                        ],
                      ),
                    )),
              )
            ],
          ),
        ],
      ),
    );
  }
}

class Speaker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        color: Colors.black54,
        height: 10,
      ),
    );
  }
}

class StreamFlipClock extends StatelessWidget {
  StreamFlipClock();

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

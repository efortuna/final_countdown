import 'package:flip_panel/flip_panel.dart';
import 'package:flutter/material.dart';

final digitWhiteTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 60,
  color: Colors.white,
);

final digitBlackTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 60,
  color: Colors.white,
);

class FlipDigit extends StatelessWidget {
  FlipDigit({
    @required this.stream,
    this.initial = 0,
  });
  final Stream<int> stream;
  final int initial;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlipPanel<int>.stream(
          itemStream: stream,
          initValue: initial,
          direction: FlipDirection.down,
          itemBuilder: (_, digit) => FlipBox('$digit')),
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
        child: Text(str, style: digitWhiteTextStyle),
      ),
    );
  }
}

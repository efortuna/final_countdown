import 'dart:io';

import 'package:flip_panel/flip_panel.dart';
import 'package:flutter/material.dart';

const digitWhiteTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 60,
  color: Colors.white,
);

const digitBlackTextStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 60,
  color: Colors.black,
);

const artDecoStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Fascinate_Inline',
  fontSize: 64,
);

const artDecoButtonStyle = TextStyle(
  fontWeight: FontWeight.bold,
  fontFamily: 'Fascinate_Inline',
  fontSize: 32,
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
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        constraints: BoxConstraints.tight(Size(120, 180)),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: FittedBox(
          fit: BoxFit.contain,
          child: Text(str, style: digitWhiteTextStyle),
        ),
      ),
    );
  }
}

class FilmImage extends StatelessWidget {
  FilmImage(this.path);
  final String path;

  @override
  Widget build(BuildContext context) {
    var filmstrip = Image.asset('assets/filmstrip_edge.jpg', height: 20);
    return Column(
      children: [
        filmstrip,
        Expanded(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Image.file(File(path)),
        )),
        filmstrip,
      ],
    );
  }
}
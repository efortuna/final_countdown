import 'package:flutter/material.dart';

import 'package:final_countdown/clocks/simple_clock.dart';
import 'package:final_countdown/data/countdown_provider.dart';
import 'package:final_countdown/styling.dart';

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
        )),
        SimpleClock(style: digitWhiteTextStyle),
      ],
    );
  }
}

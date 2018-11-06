import 'package:flutter/material.dart';

import 'package:final_countdown/simple_clock.dart';
import 'package:final_countdown/retro_clock.dart';
import 'package:final_countdown/photo_clock.dart';
import 'package:final_countdown/countdown_stream.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static final countdown = FinalCountdown(const Duration(minutes: 15));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'It\'s the final countdown!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          body: CountdownProvider(
        duration: const Duration(minutes: 15),
        child: Center(
            child: PageView(
          children: <Widget>[
            SimpleClock(countdown),
            RetroClock(countdown),
            PhotoClock(countdown),
          ],
        )),
      )),
    );
  }
}

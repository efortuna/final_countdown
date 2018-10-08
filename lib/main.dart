import 'package:flutter/material.dart';

import 'package:final_countdown/matt/countdown_animation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'It\'s the final countdown!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(body: FinalCountdownPage()),
    );
  }
}

class FinalCountdownPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Countdown(duration: Duration(minutes: 15)),
    );
  }
}

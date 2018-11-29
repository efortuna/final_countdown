import 'package:flutter/material.dart';

import 'package:final_countdown/data/countdown_provider.dart';
import 'package:final_countdown/data/file_stream_provider.dart';

import 'package:final_countdown/clocks/simple_clock.dart';
import 'package:final_countdown/clocks/retro_clock.dart';
import 'package:final_countdown/clocks/photo_clock.dart';

void main() => runApp(CountdownApp());

class CountdownApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'It\'s the final countdown!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CountdownProvider(
        duration: const Duration(minutes: 15),
        child: FileStreamProvider(child: CountdownPage()),
      ),
    );
  }
}

class CountdownPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final countdown = CountdownProvider.of(context);
    return Scaffold(
      body: PageView(
        children: <Widget>[
          PhotoClock(countdown.stream),
          SimpleClock(),
          RetroClock(),
        ],
      ),
    );
  }
}

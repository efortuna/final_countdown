import 'package:flutter/material.dart';

import 'package:final_countdown/data/controls_provider.dart';
import 'package:final_countdown/data/countdown_provider.dart';
import 'package:final_countdown/data/file_stream_provider.dart';

import 'package:final_countdown/controls.dart';
import 'package:final_countdown/clocks/simple_clock.dart';
import 'package:final_countdown/clocks/retro_clock.dart';
import 'package:final_countdown/clocks/photo_clock.dart';
import 'package:final_countdown/styling.dart';

void main() => runApp(CountdownApp());

class CountdownApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ControlsProvider(
      child: MaterialApp(
        title: 'It\'s the final countdown!',
        home: Scaffold(
          body: Builder(
            builder: (context) => StreamBuilder(
                stream: ControlsProvider.of(context).stream,
                builder: (context, snapshot) => snapshot.hasData
                    ? CountdownProvider(
                        duration: snapshot.data,
                        child: FileStreamProvider(
                          child: CountdownPage(),
                        ))
                    : CountdownControls()),
          ),
        ),
      ),
    );
  }
}

class CountdownPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RetroClock();
  }
}

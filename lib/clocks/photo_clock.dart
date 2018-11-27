import 'dart:async';

import 'package:flutter/material.dart';

import 'package:final_countdown/data/countdown_provider.dart';
import 'package:final_countdown/data/file_stream_provider.dart';
import 'package:final_countdown/utils.dart';
import 'package:final_countdown/styling.dart';
import 'package:final_countdown/clocks/simple_clock.dart';

class PhotoClock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Photographer(CountdownProvider.of(context)),
    );
  }
}

class Photographer extends StatefulWidget {
  Photographer(this.countdown);
  final CountdownProvider countdown;
  @override
  _PhotographerState createState() => _PhotographerState();
}

class _PhotographerState extends State<Photographer> {
  StreamSubscription _countdownSubscription;
  bool _frontCamera;
  Camera _camera;
  @override
  void initState() {
    _frontCamera = true;
    _camera = Camera()..takePicture();
    _countdownSubscription = widget.countdown.stream.listen((Duration d) {
      if (d.inSeconds % 60 == 0) _camera.takePicture();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FileStreamProvider.of(context).stream, 
      builder: (BuildContext context, AsyncSnapshot photosList) {
        return Column(
          children: <Widget>[
            SimpleClock(artDecoStyle),
            Image.asset('assets/camera_top.png'),
            Filmstrip(photosList.hasData ? photosList.data : []),
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Image.asset('assets/camera_bottom.png'),
                _cameraDirectionButton(),
              ],
            )
          ],
        );
      },);
  }

  _cameraDirectionButton() {
    return RaisedButton(
        color: Colors.white,
        child: Text(
            _frontCamera ? 'Use Back Camera' : 'Take Selfie',
            style: artDecoButtonStyle),
        onPressed: _camera.switchDirection);
  }

  @override
  dispose() {
    _countdownSubscription.cancel();
    super.dispose();
  }
}

class Filmstrip extends StatelessWidget {
  Filmstrip(this._photoPaths);
  final List<String> _photoPaths;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.black,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: _photoPaths.map((String s) => FilmImage(s)).toList(),
        ),
      ),
    );
  }
}

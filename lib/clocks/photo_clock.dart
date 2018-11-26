import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

import 'package:final_countdown/data/countdown_provider.dart';
import 'package:final_countdown/data/file_stream_provider.dart';
import 'package:final_countdown/utils.dart';
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
  CameraController _camera;
  CameraLensDirection _cameraDirection;
  StreamSubscription _countdownSubscription;

  @override
  void initState() {
    _cameraDirection = CameraLensDirection.front;
    takePicture();
    _countdownSubscription = widget.countdown.stream.listen((Duration d) {
      if (d.inSeconds % 60 == 0) takePicture();
    });
    super.initState();
  }

  initializeCamera() async {
    List<CameraDescription> cameraOptions = await availableCameras();
    try {
      var frontCamera = cameraOptions.firstWhere(
          (description) => description.lensDirection == _cameraDirection,
          orElse: () => cameraOptions.first);
      _camera = CameraController(frontCamera, ResolutionPreset.low);
      await _camera.initialize();
    } on StateError catch (e) {
      print('No camera found in the direction $_cameraDirection: $e');
    }
  }

  takePicture() async {
    if (_camera == null) await initializeCamera();
    var directory = await getApplicationDocumentsDirectory();
    var filename = prettyPrintDigits(await numberOfExistingPictures());
    var filePath = '${directory.path}/$filename.jpg';
    try {
      await _camera.takePicture(filePath);
    } on CameraException catch (e) {
      print('There was a problem taking the picture. $e');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FileStreamProvider.of(context).stream, 
      builder: (BuildContext context, AsyncSnapshot photosList) {
        return Column(
          children: <Widget>[
            SimpleClock(TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Fascinate_Inline',
              fontSize: 64,
            )),
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
    _switchCameraDirection() {
      setState(() => _cameraDirection =
          (_cameraDirection == CameraLensDirection.back)
              ? CameraLensDirection.front
              : CameraLensDirection.back);
    }

    return RaisedButton(
        color: Colors.white,
        child: Text(
            _cameraDirection == CameraLensDirection.back
                ? 'Take Selfie'
                : 'Use Back Camera',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Fascinate_Inline',
                fontSize: 32)),
        onPressed: _switchCameraDirection);
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

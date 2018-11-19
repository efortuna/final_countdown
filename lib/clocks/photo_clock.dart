import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

import 'package:final_countdown/data/countdown_provider.dart';
import 'package:final_countdown/clocks/simple_clock.dart';

final filmstrip = Image.asset('assets/filmstrip_edge.jpg', height: 20);

class PhotoClock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SimpleClock(TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Fascinate_Inline',
            fontSize: 64,
          )),
          Expanded(child: Photographer(CountdownProvider.of(context))),
        ],
      ),
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
  List<String> _photos;
  CameraController _controller;
  CameraLensDirection _cameraDirection;
  StreamSubscription _countdownSubscription;

  @override
  void initState() {
    _cameraDirection = CameraLensDirection.front;
    _countdownSubscription =
        widget.countdown.stream.listen((Duration currentTime) {
      if (currentTime.inSeconds % 60 == 0 && currentTime.inSeconds != 0) {
        takePicture();
      }
    });
    super.initState();
  }

  @override
  dispose() {
    _countdownSubscription.cancel();
    super.dispose();
  }

  Future<bool> populateFromStorage() async {
    Directory dir = await getApplicationDocumentsDirectory();
    _photos = dir
        .listSync()
        .where((FileSystemEntity e) => e is File)
        .map<String>((FileSystemEntity file) => file.path)
        .toList()
          ..sort();
    return true;
  }

  initializeCamera() async {
    List<CameraDescription> cameraOptions = await availableCameras();
    try {
      var frontCamera = cameraOptions.firstWhere(
          (description) => description.lensDirection == _cameraDirection,
          orElse: () => cameraOptions.first);
      _controller = CameraController(frontCamera, ResolutionPreset.low);
      await _controller.initialize();
    } on StateError catch (e) {
      print('No front-facing camera found: $e');
    }
  }

  takePicture() async {
    await initializeCamera();
    var directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/${_photos.length}.jpg';
    print('FILE APTH $filePath');
    try {
      await _controller.takePicture(filePath);
      setState(() => _photos.add(
          filePath)); //TODO: ensure that this triggers the set state thing properly.
      print('TAKIG A PICTURE!!!!!!');
    } on CameraException catch (e) {
      print('There was a problem taking the picture. $e');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: populateFromStorage(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return Column(
          children: <Widget>[
            Image.asset('assets/camera_top.png'),
            Filmstrip(snapshot.hasData ? _photos : []),
            Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Image.asset('assets/camera_bottom.png'),
                RaisedButton(
                    color: Colors.white,
                    child: Text(
                        _cameraDirection == CameraLensDirection.back
                            ? 'Front Camera'
                            : 'Back Camera',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Fascinate_Inline',
                            fontSize: 32)),
                    onPressed: switchCameraDirection),
              ],
            ),
          ],
        );
      },
    );
  }

  switchCameraDirection() {
    setState(() => _cameraDirection =
        (_cameraDirection == CameraLensDirection.back)
            ? CameraLensDirection.front
            : CameraLensDirection.back);
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
        child: _photoPaths.length == 0
            ? EmptyFilmStrip()
            : ListView(
                scrollDirection: Axis.horizontal,
                children:
                    _photoPaths.map((String s) => FilmImage(s)).toList()),
      ),
    );
  }
}

class EmptyFilmStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [filmstrip, filmstrip],
    );
  }
}

class FilmImage extends StatelessWidget {
  FilmImage(this.path);
  final String path;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        filmstrip,
        Expanded(child: Image.file(File(path))),
        filmstrip,
      ],
    );
  }
}

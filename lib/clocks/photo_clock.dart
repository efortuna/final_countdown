import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';

import 'package:final_countdown/data/countdown_provider.dart';
import 'package:final_countdown/data/storage_provider.dart';
import 'package:final_countdown/clocks/simple_clock.dart';

class PhotoClock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset('assets/camera_top.png'),
          PhotoView(PhotoStorageProvider.of(context).path),
          Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Image.asset('assets/camera_bottom.png'),
              // TODO: maybe add cool animation like "scale" in
              // https://github.com/aagarwal1012/Animated-Text-Kit
              // (but I will have to use animated widget or something else)
              SimpleClock(TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 32,
              )),
            ],
          ),
        ]);
  }
}

class PhotoView extends StatefulWidget {
  PhotoView(this.path);
  final String path;
  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  List<Widget> _photos;
  CameraController _controller;
  CameraLensDirection _cameraDirection;
  @override
  void initState() {
    _photos = populateFromStorage(context);
    print("PHOTOS HAS ${_photos.length} !!!!!!!");
    _cameraDirection = CameraLensDirection.front;
    super.initState();
  }

  List<Widget> populateFromStorage(BuildContext context) {
    return Directory(widget.path)
        .listSync()
        .where((FileSystemEntity e) => e is File)
        .map<Widget>((FileSystemEntity file) => TintedImage(file.path))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CountdownProvider.of(context).stream,
      builder: (BuildContext context, AsyncSnapshot<Duration> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.inSeconds % 60 == 0) {
            takePicture(PhotoStorageProvider.of(context).path);
          }
          return Expanded(
              child: Container(
                  color: Colors.black,
                  child: ListView(
                    children: _photos,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                  ))); // TODO: display something else if it is 0?
        } else {
          return Container(height: 200);
        }
      },
    );
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

  Future<bool> takePicture(String directory) async {
    await initializeCamera();
    var filePath = '$directory/${_photos.length}.jpg';
    print('heres the list $_photos');
    print('trying to save $filePath !!!!!!!');
    try {
      await _controller.takePicture(filePath);
      setState(() => _photos.add(TintedImage(filePath)));
      print('tok picture here: $filePath ?????????');
      switchLensDirection();
    } on CameraException catch (e) {
      print('There was a problem taking the picture. $e');
      return false;
    }
    return true;
  }

  switchLensDirection() {
    _cameraDirection = (_cameraDirection == CameraLensDirection.front)
        ? CameraLensDirection.back
        : CameraLensDirection.front;
  }
}

class TintedImage extends StatelessWidget {
  TintedImage(this.path);
  final String path;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.all(30.0),
        child: Image.file(File(path), width: 370),
      ),
      Container(color: Colors.green, width: 370, height: 100,)
      /*Opacity(
          opacity: 1,
          child: Container(
              color: calculateColor(CountdownProvider.of(context).duration)))*/
    ]);
  }

  Color calculateColor(Duration totalTime) => Color.lerp(
      Colors.red,
      Colors.yellow,
      int.parse(path.substring(
              path.lastIndexOf('/') + 1, path.lastIndexOf('.'))) /
          totalTime.inMinutes);
}

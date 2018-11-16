import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
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
          PhotoReel(PhotoStorageProvider.of(context).path),
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

class PhotoReel extends StatefulWidget {
  PhotoReel(this.path);
  final String path;
  @override
  _PhotoReelState createState() => _PhotoReelState();
}

class _PhotoReelState extends State<PhotoReel> {
  List<Widget> _photos;
  CameraController _controller;
  CameraLensDirection _cameraDirection;
  ScrollController _scrollController;
  @override
  void initState() {
    _photos = populateFromStorage(context);
    print("PHOTOS HAS ${_photos.length} !!!!!!!");
    _cameraDirection = CameraLensDirection.front;
    _scrollController = new ScrollController( 
      initialScrollOffset: 0.0,
      keepScrollOffset: true, 
    );
    super.initState();
  }

   void _scrollToEnd() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 2500), 
      curve: Curves.ease,            
    );
  } 

  void _scrollToBeginning() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 2500), 
      curve: Curves.ease,            
    );
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
          if (snapshot.data.inSeconds % 60 == 0 &&
              snapshot.data.inSeconds != 0) {
            takePicture(PhotoStorageProvider.of(context).path);
          } else if (snapshot.data.inSeconds % 10 == 5) {
            _scrollToEnd();
          } else if (snapshot.data.inSeconds % 10 == 0) {
            _scrollToBeginning();
          }
          return Expanded(
            child: Container(
              color: Colors.black,
              child: _photos.length == 0
                  ? SpinKitRipple(color: Colors.white)
                  : ListView(
                    controller: _scrollController,
                      children: _photos,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                    ),
            ),
          );
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
      setState(() => _photos = List.from(_photos)..add(TintedImage(filePath))); //TODO: order so newer iamge at top? 
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
  TintedImage(this.path) : super(key: ObjectKey(path));
  final String path;

  @override
  Widget build(BuildContext context) {
    var color = calculateColor(CountdownProvider.of(context).duration);
    return Container(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Image.file(
          File(path),
          color: color,
          colorBlendMode: BlendMode.overlay,
        ),
      ),
    );
  }

  Color calculateColor(Duration totalTime) => Color.lerp(
      Colors.red,
      Colors.yellow,
      int.parse(path.substring(
              path.lastIndexOf('/') + 1, path.lastIndexOf('.'))) /
          totalTime.inMinutes);
}

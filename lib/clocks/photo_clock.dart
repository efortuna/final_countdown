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
          // TODO(efortuna): which time location is better?
          SimpleClock(TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Fascinate_Inline',
            fontSize: 64,
          )),
          Image.asset('assets/camera_top_white.png'),
          Photographer(PhotoStorageProvider.of(context).path),
          Stack(
            alignment: AlignmentDirectional.center,
            children: <Widget>[
              Image.asset('assets/camera_bottom_white.png'),
              // TODO: maybe add cool animation like "scale" in
              // https://github.com/aagarwal1012/Animated-Text-Kit
              // (but I will have to use animated widget or something else)
              SimpleClock(TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Fascinate_Inline',
                fontSize: 64,
              )),
            ],
          ),
        ]);
  }
}

class Photographer extends StatefulWidget {
  Photographer(this.path);
  final String path;
  @override
  _PhotographerState createState() => _PhotographerState();
}

class _PhotographerState extends State<Photographer> {
  List<String> _photos;
  CameraController _controller;
  CameraLensDirection _cameraDirection;

  @override
  void initState() {
    _photos = populateFromStorage(context);
    _cameraDirection = CameraLensDirection.front;
    print("PHOTOS HAS ${_photos.length} !!!!!!!");
    super.initState();
  }

  List<String> populateFromStorage(BuildContext context) {
    return Directory(widget.path)
        .listSync()
        .where((FileSystemEntity e) => e is File)
        .map<String>((FileSystemEntity file) => file.path)
        .toList()
          ..sort();
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
      setState(() => _photos.add(
          filePath)); //TODO: ensure that this triggers the set state thing properly.
      print('tok picture here: $filePath ?????????');
    } on CameraException catch (e) {
      print('There was a problem taking the picture. $e');
      return false;
    }
    return true;
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
          }
        }
        return PhotoGrid(_photos);
      },
    );
  }
}

class PhotoGrid extends StatelessWidget {
  PhotoGrid(this._photoPaths);
  static final photosPerRow = 3;
  static final totalPhotos = photosPerRow * photosPerRow;
  final List _photoPaths;
  @override
  Widget build(BuildContext context) {
    var photoSubset = _photoPaths;
    if (_photoPaths.length > totalPhotos) {
      photoSubset = _photoPaths
          .getRange(_photoPaths.length - totalPhotos, _photoPaths.length)
          .toList();
    }
    final photos = List<TintedImage>.generate(
        totalPhotos,
        (i) => TintedImage(i / totalPhotos,
            path: photoSubset.length > i ? photoSubset[i] : null));

    var rows = List<TableRow>.generate(
        photosPerRow,
        (int i) => TableRow(
            children: photos.sublist(
                i * photosPerRow, i * photosPerRow + photosPerRow)));
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        // TODO: send PR to make Table easier to construct
        child: Table(children: rows,), 
      ),
    );
  }
}

/// Takes a path to an image, and provides a colorful border,
/// based on its location.
class TintedImage extends StatelessWidget {
  TintedImage(this.fraction, {this.path});

  /// What position this image square is in the grid, or rather what
  /// fraction of the whole. So in a nine square grid, for the first
  /// TintedImage position fraction = 1/9.
  final double fraction;
  final String path;

  /*@override
  Widget build(BuildContext context) {
    var image;
    var tint;
    if (path == null || !File(path).existsSync()) {
      image = Container(decoration: FlutterLogoDecoration());
      var countdown = CountdownProvider.of(context);
      tint = calculateColor(
          countdown.mostRecentTime.inSeconds / countdown.duration.inSeconds);
    } else {
      tint = calculateColor(fraction);
      image = Image.file(File(path), fit: BoxFit.cover);
    }
    return Stack(
        fit: StackFit.expand,
        children: [Container(
      color: tint,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: image)), Opacity(opacity: .4, child: Container(color: tint))],);
  }*/

  @override
  Widget build(BuildContext context) {
    if (path == null || !File(path).existsSync()) {
      var countdown = CountdownProvider.of(context);
      var color = calculateColor(
          countdown.mostRecentTime.inSeconds / countdown.duration.inSeconds);
      return Container(height: 110,
          decoration: FlutterLogoDecoration()); //TODO , color: color);
    }
    var color = calculateColor(fraction);
    return Container(
      color: color,
      height: 110,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          color: color,
          colorBlendMode: BlendMode.overlay,
        ),
      ),
    );
  }

  Color calculateColor(double fractionOfWhole) =>
      Color.lerp(Colors.yellow, Colors.red, fractionOfWhole);
}

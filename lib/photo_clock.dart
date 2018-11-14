import 'package:flutter/material.dart';
import 'package:final_countdown/countdown_stream.dart';
import 'package:final_countdown/utils.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class PhotoClock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridPhotoView();
  }
}

class GridPhotoView extends StatelessWidget {
  final photosPerRow = 4;

  @override
  Widget build(BuildContext context) {
    final countdown = CountdownProvider.of(context);
    final photos = List<Picture>.generate(16, (i) => Picture(countdown, i));

    var rows = List<TableRow>.generate(
        photosPerRow,
        (int i) => TableRow(
            children: photos.sublist(
                i * photosPerRow, i * photosPerRow + photosPerRow)));
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset('assets/camera_top.png'),
        Container(
          color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Table(children: rows),
          ),
        ),
        Image.asset('assets/camera_bottom.png'),
      ],
    );
  }
}

class Picture extends StatefulWidget {
  Picture(this.countdown, this.index);
  final CountdownProvider countdown;

  /// Indicator of what number this picture is, important
  /// to know when it should take a picture.
  final index;
  @override
  createState() => _PictureState();
}

class _PictureState extends State<Picture> {
  Widget _image;
  Color _color;
  StreamSubscription _colorUpdates;
  CameraController _controller;
  bool _setPicture;
  // TODO(efortuna): make the photos discoverable. Make the
  // filename particular to the DURATION point it was taken,and then
  // have some unique id for when it is first run. (perhaps address of Countdown obj?)

  @override
  initState() {
    super.initState();
    _setPicture = false;
    _image = makeClock();
    _color = Colors.yellow;
    // TODO(efortuna): I feel like there should be a better way to do this.
    _colorUpdates =
        widget.countdown.stream.listen((Duration newDuration) async {
      // Normalize rating to (0,1) and interpolate color from yellow to red as we run out of time
      setState(() {
        _color = Color.lerp(Colors.red, Colors.yellow,
            newDuration.inMinutes / widget.countdown.duration.inMinutes);
      });
      int nthImage = widget.countdown.duration.inMinutes - widget.index;
      if (newDuration.inSeconds % 60 == 0 &&
          newDuration.inMinutes == nthImage) {
        _setPicture = true;
        var filename = await takePicture();
        var countdownColor = Color.lerp(Colors.red, Colors.yellow,
            newDuration.inMinutes / widget.countdown.duration.inMinutes);
        setState(() => _image = Stack(fit: StackFit.expand, children: [
              Image.file(File(filename), fit: BoxFit.cover),
              Opacity(opacity: .7, child: Container(color: countdownColor))
            ]));
      } else if (!_setPicture && newDuration.inMinutes < nthImage) {
        setState(() => _image = Image.asset(
            'assets/beaker_by_david_goehring.jpg',
            fit: BoxFit.cover));
        _setPicture = true;
      }
    });
  }

  initializeCamera() async {
    List<CameraDescription> cameraOptions = await availableCameras();
    try {
      var frontCamera = cameraOptions.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
      _controller = CameraController(frontCamera, ResolutionPreset.low);
      await _controller.initialize();
    } on StateError catch (e) {
      print('No front-facing camera found: $e');
    }
  }

  Future<String> takePicture() async {
    await initializeCamera();
    Directory extDir = await getApplicationDocumentsDirectory();
    var dirPath = '${extDir.path}/Pictures/clock_app';
    await Directory(dirPath).create(recursive: true);
    var filePath = '$dirPath/${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      await _controller.takePicture(filePath);
    } on CameraException catch (e) {
      print('There was a problem taking the picture. $e');
      return null;
    }
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: AnimatedContainer(
          height: 100,
          color: _color,
          child: _image,
          duration: const Duration(milliseconds: 500)),
    );
  }

  @override
  deactivate() {
    _colorUpdates.cancel();
    super.deactivate();
  }

  makeClock() => StreamBuilder(
        stream: widget.countdown.stream,
        builder: (context, AsyncSnapshot<Duration> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Waiting ...');
            case ConnectionState.active:
              return Center(
                  child: Text('${prettyPrintDuration(snapshot.data)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 32)));
            case ConnectionState.done:
              return Text('Time\s up!');
            case ConnectionState.none:
              return Text('Entered oblivion; this should never have happened');
          }
        },
      );
}

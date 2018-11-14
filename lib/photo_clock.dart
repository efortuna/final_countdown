import 'package:flutter/material.dart';
import 'package:final_countdown/countdown_stream.dart';
import 'package:final_countdown/utils.dart';
import 'package:camera/camera.dart';
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
  CameraLensDirection _cameraDirection;
  bool _flipRed;
  String _filePath;
  // Reversing the index so that we start at the top left instead of the bottom right.
  int _reverseIndex;

  @override
  initState() {
    super.initState();
    // Search for existing picture.
    _filePath = '${widget.countdown.storage.path}/picture${widget.index}.jpg';
    _flipRed = true;
    _cameraDirection = CameraLensDirection.front;
    _reverseIndex = widget.countdown.duration.inMinutes - widget.index;
    _color = Colors.yellow;

    if (widget.countdown.mostRecentTime.inMinutes < _reverseIndex) {
      _image = makeTintedImage(calculateColor(widget.countdown.mostRecentTime));
    } else {
      _image = makeClock();
    }

    // TODO(efortuna): I feel like there should be a better way to do this.
    _colorUpdates =
        widget.countdown.stream.listen((Duration newDuration) async {
      var calculatedColor = calculateColor(newDuration);
      setState(() {
        _color = calculatedColor;
      });
      if (newDuration.inMinutes == _reverseIndex &&
          newDuration.inSeconds % 60 == 0) {
        await takePicture();
        setState(() => _image = makeTintedImage(calculatedColor));
      }
    });
  }

  Widget makeTintedImage(Color tint) {
    return Stack(fit: StackFit.expand, children: [
      Image.file(File(_filePath), fit: BoxFit.cover),
      Opacity(opacity: .7, child: Container(color: tint))
    ]);
  }

  Color calculateColor(Duration currentDuration) {
    // TODO: can I akways just use most recent duration?
    if (currentDuration.inMinutes == _reverseIndex &&
        currentDuration.inSeconds % 60 < 10 &&
        currentDuration.inSeconds % 60 != 0) {
      // Create "flashing" effect in the last 10 seconds before taking a picture.
      _flipRed = !_flipRed;
      return _flipRed ? Colors.red : Colors.yellow;
    }
    return Color.lerp(Colors.red, Colors.yellow,
        currentDuration.inMinutes / widget.countdown.duration.inMinutes);
  }

  initializeCamera() async {
    List<CameraDescription> cameraOptions = await availableCameras();
    try {
      var frontCamera = cameraOptions.firstWhere(
          (description) => description.lensDirection == _cameraDirection);
      _controller = CameraController(frontCamera, ResolutionPreset.low);
      await _controller.initialize();
    } on StateError catch (e) {
      print('No front-facing camera found: $e');
    }
    // Alternatively this can be triggered by a button.
    switchCameraLensDirection();
  }

  switchCameraLensDirection() {
    _cameraDirection = (_cameraDirection == CameraLensDirection.front)
        ? CameraLensDirection.back
        : CameraLensDirection.front;
  }

  Future<bool> takePicture() async {
    await initializeCamera();
    try {
      await _controller.takePicture(_filePath);
    } on CameraException catch (e) {
      print('There was a problem taking the picture. $e');
      return false;
    }
    return true;
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

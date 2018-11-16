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
          SimpleClock(TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Fascinate',
                fontSize: 32,
              )),
          Image.asset('assets/camera_top_white.png'),
          PhotoReel(PhotoStorageProvider.of(context).path),
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
          } else if (snapshot.data.inSeconds % 10 == 5 && snapshot.data.inSeconds != 0) {
            _scrollToEnd();
          } else if (snapshot.data.inSeconds % 10 == 0 && snapshot.data.inSeconds != 0) {
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



///////////////////////////////
/*import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:camera/camera.dart';

import 'package:final_countdown/data/countdown_provider.dart';
import 'package:final_countdown/data/storage_provider.dart';
import 'package:final_countdown/clocks/simple_clock.dart';

class PhotoClock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridPhotoView();
  }
}

class GridPhotoView extends StatelessWidget {
  static final photosPerRow = 4;
  static final totalPhotos = photosPerRow * photosPerRow;

  @override
  Widget build(BuildContext context) {
    final countdown = CountdownProvider.of(context);
    final storage = PhotoStorageProvider.of(context);
    final photos = List<TintedImage>.generate(
        totalPhotos, (i) => TintedImage(countdown, storage, i, totalPhotos));

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

class TintedImage extends StatefulWidget {
  TintedImage(this.countdown, this.storage, this.index, this.totalTiles);
  final CountdownProvider countdown;
  final PhotoDirectory storage;
  final totalTiles;

  /// Indicator of what number this picture is, important
  /// to know when it should take a picture.
  final index;
  @override
  createState() => _TintedImageState();
}

class _TintedImageState extends State<TintedImage> {
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
    _filePath = '${widget.storage.path}/picture${widget.index}.jpg';
    _flipRed = true;
    _reverseIndex = widget.countdown.duration.inMinutes - widget.index;
    _cameraDirection = _reverseIndex % 2 == 0 ? CameraLensDirection.front : CameraLensDirection.back;
    _color = Colors.yellow;

    if (widget.countdown.mostRecentTime.inMinutes < _reverseIndex) {
      _image = makeTintedImage(calculateColor());
    } else {
      _image = SimpleClock(
        TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      );
    }

    // TODO(efortuna): I feel like there should be a better way to do this.
    _colorUpdates =
        widget.countdown.stream.listen((Duration newDuration) async {
      var calculatedColor = calculateColor(duration: newDuration);
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
    var image;
    var file = File(_filePath);
    if (file.existsSync()) {
      image = Image.file(File(_filePath), fit: BoxFit.cover);
    } else {
      image = Container(decoration: FlutterLogoDecoration());
    }
    return Stack(
        fit: StackFit.expand,
        children: [image, Opacity(opacity: .4, child: Container(color: tint))]);
  }

  Color calculateColor({Duration duration}) {
    if (duration == null) {
      return Color.lerp(
          Colors.red, Colors.yellow, _reverseIndex / widget.totalTiles);
    }
    if (duration.inMinutes == _reverseIndex &&
        duration.inSeconds % 60 < 10 &&
        duration.inSeconds % 60 != 0) {
      // Create "flashing" effect in the last 10 seconds before taking a picture.
      _flipRed = !_flipRed;
      return _flipRed ? Colors.red : Colors.yellow;
    }
    return Color.lerp(Colors.red, Colors.yellow,
        duration.inMinutes / widget.countdown.duration.inMinutes);
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
}
*/
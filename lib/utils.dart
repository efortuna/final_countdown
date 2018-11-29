import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';

/// Returns a human-readable representation of a duration
String prettyPrintDuration(Duration duration, [showSeparator = true]) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  final separator = showSeparator ? ':' : ' ';
  return '$minutes$separator${prettyPrintDigits(seconds)}';
}

String prettyPrintDigits(int num) => num >= 10 ? '$num' : '0$num';

/// Normally this would be part of Photographer widget, but moving here to
/// minimize extra code.
Future<int> numberOfExistingPictures() async {
  Directory dir = await getApplicationDocumentsDirectory();
  var photos = dir
      .listSync()
      .where((FileSystemEntity e) => e is File && e.path.endsWith('jpg'))
      .map<String>((FileSystemEntity file) => file.path)
      .toList();
  return photos.length;
}

class Camera {
  Camera() {
    _initializeCameras();
  }

  CameraController _frontCamera, _backCamera;
  CameraLensDirection _cameraDirection = CameraLensDirection.front;

  _initializeCameras() async {
    List<CameraDescription> cameraOptions = await availableCameras();
    try {
      getCamera(CameraLensDirection direction) => cameraOptions.firstWhere(
          (description) => description.lensDirection == direction,
          orElse: () => cameraOptions.first);
      _frontCamera = CameraController(getCamera(CameraLensDirection.front), ResolutionPreset.low);
      _backCamera = CameraController(getCamera(CameraLensDirection.back), ResolutionPreset.low);
      await _frontCamera.initialize();
      await _backCamera.initialize();
    } on StateError catch (e) {
      print('No camera found in the direction $_cameraDirection: $e');
    }
  }

  takePicture() async {
    var directory = await getApplicationDocumentsDirectory();
    var filename = prettyPrintDigits(await numberOfExistingPictures());
    var filePath = '${directory.path}/$filename.jpg';
    try {
      var camera = _cameraDirection == CameraLensDirection.front ? _frontCamera : _backCamera;
      await camera.takePicture(filePath);
    } on CameraException catch (e) {
      print('There was a problem taking the picture. $e');
      return false;
    }
    return true;
  }

  switchDirection() {
    _cameraDirection =
          (_cameraDirection == CameraLensDirection.back)
              ? CameraLensDirection.front
              : CameraLensDirection.back;
  }
}
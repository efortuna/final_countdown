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
  CameraController _camera;
  CameraLensDirection _cameraDirection = CameraLensDirection.front;

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

  switchDirection() {
    _cameraDirection =
          (_cameraDirection == CameraLensDirection.back)
              ? CameraLensDirection.front
              : CameraLensDirection.back;
    _camera = null;
  }
}
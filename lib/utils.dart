import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

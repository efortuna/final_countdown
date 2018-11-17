import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

const durationKey = 'duration';
const photoStorageKey = 'photoStorage';

Future<Duration> loadDuration(Duration defaultDuration) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return Duration(
      milliseconds:
          prefs.getInt(durationKey) ?? defaultDuration.inMilliseconds);
}

void saveDuration(Duration duration) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(durationKey, duration.inMilliseconds);
}

void deleteDuration() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(durationKey);
  await prefs.remove(photoStorageKey);
}

Future<Directory> loadStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String dirname = prefs.getString(photoStorageKey);
  if (dirname == null) {
    Directory dir = await getApplicationDocumentsDirectory();
    dirname = dir.path;
    await prefs.setString(photoStorageKey, dirname);
  }
  return Directory(dirname);
}
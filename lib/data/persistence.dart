import 'package:shared_preferences/shared_preferences.dart';

const durationKey = 'duration';
const photoStorageKey = 'photoStorage';

Future<Duration> loadDuration(Duration defaultDuration) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return Duration(
      milliseconds:
          prefs.getInt(durationKey) ?? defaultDuration.inMilliseconds);
}

void saveDuration(Duration duration) async {
  print('Saving Duration');
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt(durationKey, duration.inMilliseconds);
}

void deleteDuration() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(durationKey);
  await prefs.remove(photoStorageKey);
}

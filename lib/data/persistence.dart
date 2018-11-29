import 'package:shared_preferences/shared_preferences.dart';

const durationKey = 'duration';

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
}

/// Returns the duration if it exists, false if not
Future<Duration> hasDuration() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final duration = prefs.getInt(durationKey);
  return duration != null ? Duration(milliseconds: duration) : null;
}

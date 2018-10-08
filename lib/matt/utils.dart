/// Returns a human-readable representation of a duration
String prettyPrintDuration(Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  final minutesStr = minutes >= 10 ? '$minutes' : '0$minutes';
  final secondsStr = seconds >= 10 ? '$seconds' : '0$seconds';

  return '$minutesStr:$secondsStr';
}

/// Returns a human-readable representation of a duration
String prettyPrintDuration(Duration duration, [showSeparator = true]) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  final separator = showSeparator ? ':' : ' ';
  return '${prettyPrintDigits(minutes)}$separator${prettyPrintDigits(seconds)}';
}

String prettyPrintDigits(int num) => num >= 10 ? '$num' : '0$num';

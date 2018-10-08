import 'package:flutter/widgets.dart';

import 'package:final_countdown/matt/utils.dart';

class TextDuration extends StatelessWidget {
  TextDuration({this.duration});
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final showSeparator = duration.inSeconds % 2 == 0;
    return Text(prettyPrintDuration(duration, showSeparator));
    ;
  }
}

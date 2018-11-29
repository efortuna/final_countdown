import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:final_countdown/data/persistence.dart';

/// Stream to control the start and duration of the
/// countdown
class ControlsProvider extends InheritedWidget {
  ControlsProvider({Key key, @required Widget child})
      : assert(child != null),
        super(key: key, child: child) {
    _init();
  }

  void _init() async {
    final duration = await hasDuration();
    if (duration != null) {
      _controller.add(duration);
    }
  }

  final _controller = new StreamController<Duration>();

  Stream<Duration> get stream => _controller.stream;

  void start(Duration duration) {
    assert(duration != null);
    _controller.add(duration);
  }

  static ControlsProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(ControlsProvider);

  @override
  bool updateShouldNotify(InheritedWidget _) => false;

  void dispose() => _controller?.close();
}

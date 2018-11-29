import 'dart:async';

import 'package:final_countdown/data/persistence.dart';

class FinalCountdownTimer {
  FinalCountdownTimer({
    this.frequency = const Duration(seconds: 1),
  });

  final Duration frequency;
  final _controller = StreamController<Duration>();

  Timer _timer;
  Duration _remaining;

  Duration get remaining => _remaining;
  Stream<Duration> get stream => _controller.stream;

  start(Duration duration) {
    if (_timer == null) {
      _remaining = duration;
      _timer = Timer.periodic(frequency, (t) {
        _controller.add(_remaining);
        _remaining -= frequency;
        if (_remaining < const Duration()) {
          t.cancel();
          _controller.close();
        }
      });
    }
  }

  void dispose() {
    _timer?.cancel();
    _controller?.close();
  }
}

class PersistedFinalCountdown {
  PersistedFinalCountdown(
    this.startingDuration, {
    Duration frequency = const Duration(seconds: 1),
  }) {
    _init(startingDuration, frequency);
  }

  _init(Duration startingDuration, Duration frequency) async {
    final duration = await loadDuration(startingDuration);
    _countdown = FinalCountdownTimer(frequency: frequency);

    // Add the countdown stream to the controller and delete cache when finished
    _countdown.stream.pipe(_controller).then((_) => deleteDuration());
    // Persist the countdown
    stream.listen(saveDuration);

    // Auto-start the countdown if it was persisted
    if (duration != startingDuration) {
      _countdown.start(duration);
    }
  }

  final Duration startingDuration;
  final _controller = StreamController<Duration>.broadcast();

  FinalCountdownTimer _countdown;

  Stream<Duration> get stream => _controller.stream;
  Duration get remaining => _countdown.remaining;

  void start(Duration duration) => _countdown.start(duration);

  void dispose() {
    _countdown?.dispose();
    _controller?.close();
  }
}

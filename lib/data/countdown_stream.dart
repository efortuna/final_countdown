import 'dart:async';

import 'package:final_countdown/data/persistence.dart';

class FinalCountdown {
  FinalCountdown(
    this.duration, {
    this.frequency = const Duration(seconds: 1),
  });

  final Duration duration;
  final Duration frequency;

  Duration _remaining;
  Duration get remaining => _remaining;

  Stream<Duration> get stream async* {
    _remaining = duration;
    while (_remaining >= const Duration()) {
      yield _remaining;
      _remaining -= frequency;
      await Future.delayed(frequency);
    }
  }
}

class PersistedFinalCountdown {
  PersistedFinalCountdown(
    Duration startingDuration, {
    Duration frequency = const Duration(seconds: 1),
  }) {
    _init(startingDuration, frequency);
  }

  _init(Duration startingDuration, Duration frequency) async {
    final duration = await loadDuration(startingDuration);
    _countdown = FinalCountdown(duration, frequency: frequency);
    _controller.addStream(_countdown.stream);
    // Persist the countdown and delete the cache when done
    stream.listen(saveDuration, onDone: deleteDuration);
  }

  final _controller = StreamController<Duration>.broadcast();
  FinalCountdown _countdown;

  Stream<Duration> get stream => _controller.stream;
  Duration get duration => _countdown.duration;
  Duration get remaining => _countdown.remaining;

  dispose() => _controller?.close();
}

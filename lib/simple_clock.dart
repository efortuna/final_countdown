import 'package:flutter/widgets.dart';
import 'package:final_countdown/countdown_stream.dart';
import 'package:final_countdown/utils.dart';

class SimpleClock extends StatelessWidget {
  SimpleClock(this.countdown);
  final FinalCountdown countdown;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Builder(
        builder: (context) => StreamBuilder(
              stream: countdown.time, //CountdownProvider.of(context).countdown,
              builder: (context, AsyncSnapshot<Duration> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text('Waiting ...');
                  case ConnectionState.active:
                    return Text('Time ${prettyPrintDuration(snapshot.data)}');
                  case ConnectionState.done:
                    return Text('Time\s up!');
                  case ConnectionState.none:
                    return Text(
                        'Entered oblivion; this should never have happened');
                }
              },
            ),
      ),
    );
  }
}

import 'package:flutter/widgets.dart';
import 'package:final_countdown/countdown_stream.dart';
import 'package:final_countdown/utils.dart';

class SimpleClock extends StatelessWidget {
  SimpleClock({this.style});

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Builder(
        builder: (context) => StreamBuilder(
              stream: CountdownProvider.of(context).stream,
              builder: (context, AsyncSnapshot<Duration> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Text('Waiting ...', style: style);
                  case ConnectionState.active:
                    return Text('${prettyPrintDuration(snapshot.data)}', style: style);
                  case ConnectionState.done:
                    return Text('Time\s up!', style: style);
                  case ConnectionState.none:
                    return Text(
                        'Entered oblivion; this should never have happened', style: style);
                }
              },
            ),
      ),
    );
  }
}

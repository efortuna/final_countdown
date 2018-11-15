import 'package:flutter/widgets.dart';

import 'package:final_countdown/data/countdown_stream.dart';
import 'package:final_countdown/utils.dart';

class SimpleClock extends StatelessWidget {
  SimpleClock([this.style]);
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder(
        stream: CountdownProvider.of(context).stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Text('Waiting ...', style: style);

            case ConnectionState.active:
              return Text(
                prettyPrintDuration(snapshot.data),
                style: style,
              );

            case ConnectionState.done:
              return Text('Time\s up!', style: style);
          }
        },
      ),
    );
  }
}

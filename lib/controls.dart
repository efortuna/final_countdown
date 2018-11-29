import 'package:final_countdown/data/countdown_provider.dart';
import 'package:flutter/material.dart';

import 'package:final_countdown/styling.dart';
import 'package:final_countdown/utils.dart';

class CountdownControls extends StatefulWidget {
  @override
  createState() => CountdownControlsState();
}

class CountdownControlsState extends State<CountdownControls> {
  var startTime = 30;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            prettyPrintDuration(Duration(minutes: startTime)),
            style: digitBlackTextStyle,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<int>(
                value: startTime,
                items: [
                  DropdownMenuItem(value: 30, child: Text('30 mins')),
                  DropdownMenuItem(value: 25, child: Text('25 mins')),
                  DropdownMenuItem(value: 20, child: Text('20 mins')),
                  DropdownMenuItem(value: 15, child: Text('15 mins')),
                  DropdownMenuItem(value: 10, child: Text('10 mins')),
                  DropdownMenuItem(value: 5, child: Text('5 mins')),
                  DropdownMenuItem(value: 1, child: Text('1 min')),
                ],
                onChanged: (v) => setState(() => startTime = v),
              ),
              SizedBox(width: 30),
              RaisedButton(
                  child: Text('Start'),
                  onPressed: () => CountdownProvider.of(context).start(
                        Duration(minutes: startTime),
                      )),
            ],
          ),
        ],
      ),
    );
  }
}

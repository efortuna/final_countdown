import 'package:flutter/material.dart';
import 'package:final_countdown/countdown_stream.dart';
import 'package:final_countdown/utils.dart';
import 'dart:async';

class PhotoClock extends StatelessWidget {
  PhotoClock(this.countdown);
  final FinalCountdown countdown;
  @override
  Widget build(BuildContext context) {
    return GridPhotoView(countdown);
  }
}

class GridPhotoView extends StatelessWidget {
  GridPhotoView(this.countdown);
  final FinalCountdown
      countdown; // TODO(efortuna): Make accessible via inherited widget?
  @override
  Widget build(BuildContext context) {
    var rows = List<TableRow>.generate(
        4,
        (int i) => TableRow(
            children:
                List<Picture>.generate(4, (int j) => Picture(countdown))));
    return Table(children: rows);
  }
}

class Picture extends StatefulWidget {
  Picture(this.countdown);
  final FinalCountdown countdown;
  @override
  _PictureState createState() => _PictureState();
}

class _PictureState extends State<Picture> {
  Widget _image;
  // Normalize rating to (0,1) and interpolate color from green to red as we run out of time
  Color _color;
  StreamSubscription _colorUpdates;

  @override
  initState() {
    super.initState();
    _image = timer();
    _color = Colors.green;
    // TODO(efortuna): I feel like there should be a better way to do this.
    _colorUpdates = widget.countdown.time.listen((Duration newDuration) {
      setState(() {_color = Color.lerp(
                  Colors.red,
                  Colors.green,
                  newDuration.inMinutes /
                      widget.countdown.duration.inMinutes);
              });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child:
          AnimatedContainer(height: 100.0, width: 100.0, color: _color, child: _image, duration: const Duration(milliseconds: 500)),
    );
  }

  @override
  deactivate() {
    _colorUpdates.cancel();
    super.deactivate();
  }
  
  timer() => StreamBuilder(
        stream: widget.countdown.time,
        builder: (context, AsyncSnapshot<Duration> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Waiting ...');
            case ConnectionState.active:
              return Text('Time ${prettyPrintDuration(snapshot.data)}');
            case ConnectionState.done:
              return Text('Time\s up!');
            case ConnectionState.none:
              return Text('Entered oblivion; this should never have happened');
          }
        },
      );
}

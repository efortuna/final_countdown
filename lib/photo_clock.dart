import 'package:flutter/material.dart';
import 'package:final_countdown/countdown_stream.dart';
import 'package:final_countdown/utils.dart';

class PhotoClock extends StatelessWidget {
  PhotoClock(this.time);
  final FinalCountdown time;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        StreamBuilder(stream: time.time,
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
        Picture(),
      ],
    );
  }
}

/*class GridPhotoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Picture(),
    );
  }
}*/

class Picture extends StatefulWidget {
  @override
  _PictureState createState() => _PictureState();
}

class _PictureState extends State<Picture> {
  double size = 200.0;

  @override
    void initState() {
      super.initState();
      Future.delayed(const Duration(seconds: 3)).then((_) => setState(() => size = 20.0));
    }
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(height: size, child: Image.asset('assets/wood.jpg'), duration: const Duration(seconds: 3));
  }
}
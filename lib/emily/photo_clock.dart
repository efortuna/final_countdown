// Inspired by: https://medium.com/flutter-community/make-3d-flip-animation-in-flutter-16c006bb3798
import 'package:flutter/material.dart';
import 'package:flip_panel/flip_panel.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

class Countdown extends StatelessWidget {
  Countdown({this.duration});
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ImagePicker.pickImage(source: ImageSource.camera),
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.hasData) {
            /*Future.delayed(Duration(seconds: 3)).then((_) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => GridPhotoView()));
          });*/
            return PhotoView(snapshot.data);
          } else {
            return Text('No image. Weird.');
          }
        });
  }
}

class PhotoView extends StatefulWidget {
  PhotoView(this.photoFile);
  final File photoFile;
  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), moveToGridView);
  }

  @override
  Widget build(BuildContext context) {
    return Hero(tag: 'hi', child: Image.asset('assets/wood.jpg'));
    return Image.file(widget.photoFile);
  }

  moveToGridView() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => GridPhotoView()));
  }
}

class GridPhotoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Picture()/*Table(children: [
        //TableRow(children: [Text('hello there')]),
        TableRow(children: [Picture()]),
      ])*/,
    );
  }
}

class Picture extends StatefulWidget {
  @override
  _PictureState createState() => _PictureState();
}

class _PictureState extends State<Picture> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(future: Future.delayed(const Duration(seconds: 5), () => true),
      builder: (BuildContext context, AsyncSnapshot<bool> completed) {
        if (completed.hasData) {
          return Hero(tag: 'hi', child: Image.asset('assets/wood.jpg', height: 20.0));
        }
        return Hero(tag: 'hi', child: Image.asset('assets/wood.jpg', height: 20.0));
        return Container(height: 20.0, color: Colors.red);
      })
    );
  }
}

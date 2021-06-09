import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:screenshot/screenshot.dart';

class ResultCanvasImage extends StatefulWidget {
  final Uint8List imageData;
  final double top;
  final EdgeInsets padding;
  const ResultCanvasImage(
      {Key key,
      @required this.imageData,
      this.top,
      this.padding = EdgeInsets.zero})
      : super(key: key);

  @override
  ResultCanvasImageState createState() => ResultCanvasImageState();
}

class ResultCanvasImageState extends State<ResultCanvasImage> {
  ScreenshotController screenshotController = ScreenshotController();
  Size size = Size(800, 800);

  Future<Uint8List> getImage(Size size,
      {double scale = 1.0, bool debug = false}) async {
    setState(() {
      this.size = size;
    });
    final result =
        await screenshotController.capture(delay: Duration(milliseconds: 250));

    return result;
  }

  void resetSize() {
    setState(() {
      size = Size(800, 800);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
          child: Screenshot(
        controller: screenshotController,
        child: Container(
          color: Colors.white,
          padding: widget.padding,
          child: Image.memory(
            widget.imageData,
            width: size.width,
            height: size.height,
            fit: BoxFit.contain,
          ),
        ),
      )),
    );
  }
}

class ImagePainter extends CustomPainter {
  final Uint8List imageData;

  ImagePainter(this.imageData);
  @override
  void paint(Canvas canvas, Size size) {
    drawImage(imageData, canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

void drawImage(Uint8List imageData, Canvas canvas, Size size,
    {double scale = 1.0, double top = 0, bool debug = false}) {
  final child = Container(
    color: Colors.black,
    child: Center(
        child: Image.memory(
      imageData,
      width: 800,
      height: 800,
      fit: BoxFit.contain,
    )),
  );
}

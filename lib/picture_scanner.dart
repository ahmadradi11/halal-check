// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:halal_check/result_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'detector_painters.dart';
//import 'package:mlkit/mlkit.dart';

class PictureScanner extends StatefulWidget {
  final String imagePath;

  const PictureScanner({Key key, this.imagePath}) : super(key: key);

  @override
  _PictureScannerState createState() => _PictureScannerState();
}

class _PictureScannerState extends State<PictureScanner> {
  File _imageFile;
  Size _imageSize;
  Detector _currentDetector = Detector.cloudText;
  dynamic _scanResults;
  final TextRecognizer _recognizer = FirebaseVision.instance.textRecognizer();
  final TextRecognizer _cloudRecognizer =
      FirebaseVision.instance.cloudTextRecognizer();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  initState() {
    super.initState();
    _getAndScanImage();
  }

  Future<void> _getAndScanImage() async {
    setState(() {
      _imageFile = null;
      _imageSize = null;
    });

    final File imageFile = await File(widget.imagePath).exists()? File(widget.imagePath): null;

    if (imageFile != null) {
      _getImageSize(imageFile);
      _scanImage(imageFile);
      print('imagefile is not null');
    } else {
      print('imagefile is null');
    }

    setState(() {
      _imageFile = imageFile;
    });
  }

  Future<void> _getImageSize(File imageFile) async {
    final Completer<Size> completer = Completer<Size>();

    final Image image = Image.file(imageFile);
    image.image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        ));
      }),
    );

    final Size imageSize = await completer.future;
    setState(() {
      _imageSize = imageSize;
    });
    print("in getimagesize");
  }

  Future<void> _scanImage(File imageFile) async {
    setState(() {
      _scanResults = null;
    });

    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    dynamic results;
    switch (_currentDetector) {
      case Detector.text:
        results = await _recognizer.processImage(visionImage);
        break;
      case Detector.cloudText:
        results = await _cloudRecognizer.processImage(visionImage);
        break;
      default:
        return;
    }

    setState(() {
      _scanResults = results;
    });
    print("in scanimage");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Halal Check'),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<Detector>(
            onSelected: (Detector result) {
              _currentDetector = result;
              if (_imageFile != null) _scanImage(_imageFile);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Detector>>[
              const PopupMenuItem<Detector>(
                child: Text('Cloud Detection'),
                value: Detector.cloudText,
              ),
              const PopupMenuItem<Detector>(
                child: Text('On-device Detection'),
                value: Detector.text,
              ),
            ],
          ),
        ],
      ),
      body: ResultBuilder(
        scaffoldKey: scaffoldKey,
        imageSize: _imageSize,
        scanResults: _scanResults,
        imageFile: _imageFile,
      ),
    );
  }

  @override
  void dispose() {
    _recognizer.close();
    _cloudRecognizer.close();
    super.dispose();
  }
}

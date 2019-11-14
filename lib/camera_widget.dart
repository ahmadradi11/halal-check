import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:halal_check/picture_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: CameraWidget(),
    ),
  );
}

class CameraWidget extends StatefulWidget {
  @override
  CameraState createState() => CameraState();
}

class CameraState extends State<CameraWidget> {
  List<CameraDescription> cameras;
  CameraController controller;
  Future<void> _initializeControllerFuture;
  bool isReady = false;
  bool showCamera = true;
  String imagePath;

  @override
  void initState() {
    super.initState();
    setupCameras();
  }

  Future<void> setupCameras() async {

    try {
      cameras = await availableCameras();
      controller = new CameraController(cameras[0], ResolutionPreset.medium);
      await controller.initialize();
    } on CameraException catch (_) {
      setState(() {
        isReady = false;
      });
    }
    setState(() {
      isReady = true;
    });

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });
  }

  Widget build(BuildContext context) {
    print("build camerawidget");
    return Scaffold(
      appBar: AppBar(
          title: Text('Halal Check'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              onPressed: getPictureFromGallery,
              icon: Icon(Icons.add_photo_alternate),
            ),
          ]),
      body: cameraPreviewWidget(),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
        ),
        backgroundColor: Color.fromRGBO(35, 35, 35, 1.0),
        // Provide an onPressed callback.
        onPressed: controller != null && controller.value.isInitialized
            ? onTakePictureButtonPressed
            : null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget cameraPreviewWidget() {
    if (!isReady || !controller.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }
    return CameraPreview(controller);
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          showCamera = false;
          imagePath = filePath;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PictureScanner(imagePath: imagePath),
          ),
        );
      }
    });
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      return null;
    }
    // Store the picture in the temp directory.
    // Find the temp directory using the `path_provider` plugin.
    final String filePath =
        '${(await getTemporaryDirectory()).path}/${DateTime.now()}.png';

    if (controller.value.isTakingPicture) {
      return null;
    }

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
  }

  Future<void> getPictureFromGallery() async {
    final File imageFile =
    await ImagePicker.pickImage(source: ImageSource.gallery);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PictureScanner(imagePath: imageFile.path),
      ),
    );
  }

  void dispose() {
    // Dispose of the controller when the widget is disposed.
    controller.dispose();
    super.dispose();
  }
}

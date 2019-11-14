import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'detector_painters.dart';

class ResultBuilder extends StatefulWidget {
  final imageSize;
  final scanResults;
  final imageFile;

  ResultBuilder(
      {Key key,
      this.scaffoldKey,
      this.imageSize,
      this.scanResults,
      this.imageFile})
      : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _ResultBuilderState createState() => new _ResultBuilderState();
}

class _ResultBuilderState extends State<ResultBuilder> {
  Detector _currentDetector = Detector.text;
  List<String> detectedHaramProduct = new List();
  List<String> detectedSyubhahProduct = new List();
  bool isHaram = false;
  bool isSyubhah = false;

  CustomPaint _buildResults(Size imageSize, dynamic results) {
    CustomPainter painter;
    switch (_currentDetector) {
      case Detector.text:
        painter = TextDetectorPainter(widget.imageSize, results);
        break;
      case Detector.cloudText:
        painter = TextDetectorPainter(widget.imageSize, results);
        break;
      default:
        break;
    }

    return CustomPaint(
      painter: painter,
    );
  }

  Future checkHalal() async {
    var product;
    for (TextBlock block in widget.scanResults.blocks) {
      for (TextLine line in block.lines) {
        print(line.text);
        for (TextElement element in line.elements) {
          final String text = element.text;
          if (haramProduct.contains(text) &&
              !detectedHaramProduct.contains(text)) {
            detectedHaramProduct.add(text);
            isHaram = true;
          } else if (syubhahProduct.contains(text) &&
              !detectedSyubhahProduct.contains(text)) {
            detectedSyubhahProduct.add(text);
            isSyubhah = true;
          }
        }
      }
      product = detectedHaramProduct;
//      product.asMap();
      print('haram product : $product');
    }
  }

  String collapsedHalalcheck() {
    return isHaram
        ? 'This product is Haram'
        : isSyubhah ? 'This product is Syubhah' : 'This product is Halal';
  }

  Widget _buildImage() {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: Image.file(widget.imageFile).image,
          fit: BoxFit.fill,
        ),
      ),
      child: widget.imageSize == null || widget.scanResults == null
          ? const Center(
              child: Text(
                'Scanning...',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 30.0,
                ),
              ),
            )
          : _buildResults(widget.imageSize, widget.scanResults),
    );
  }

  BorderRadiusGeometry radius = BorderRadius.only(
    topLeft: Radius.circular(30.0),
    topRight: Radius.circular(30.0),
  );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        body: Stack(
      children: <Widget>[
        _buildImage(),
        SlidingUpPanel(
          panel: _floatingPanel(),
          collapsed: _floatingCollapsed(),
          borderRadius: radius,
//          margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
        ),
      ],
    ));
  }

  Widget _floatingCollapsed() {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(35, 35, 35, 1.0),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
      ),
//      margin: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
      child: Center(
        child: Text(collapsedHalalcheck(),
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _floatingPanel() {
    checkHalal();
    return Container(
      decoration: BoxDecoration(
        color: Color.fromRGBO(35, 35, 35, 1.0),
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0), topRight: Radius.circular(24.0)),
      ),
//      margin: const EdgeInsets.all(24.0),
      child: Column(
        children: <Widget>[
          Text('Haram Ingredient', style: TextStyle(color: Colors.red)),
          Container(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: detectedHaramProduct.length,
              itemBuilder: (context, idx) {
                return Center(
                  child: Text(detectedHaramProduct[idx]),
                );
              },
            ),
          ),
          Text('Syubhah Ingredient', style: TextStyle(color: Colors.yellow)),
          Container(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: detectedSyubhahProduct.length,
              itemBuilder: (context, idx) {
                return Center(
                  child: Text(detectedSyubhahProduct[idx]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        Text('Haram Product', style: TextStyle(color: Colors.red)),
//          Text(painter.detectedHaramProduct[index], style: TextStyle(color: Colors.white)),
        Text('Syubhah Product', style: TextStyle(color: Colors.yellow)),
//          Text(painter.detectedSyubhahProduct[index], style: TextStyle(color: Colors.white)),
      ],
    );
  }
}

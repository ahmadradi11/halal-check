// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';

var haramProduct = [
  '豚肉',
  '牛肉',
  '鶏肉',
  '清酒',
  'アルコール',
  'みりん',
  'ゼラチン',
  'チキン',
  'ハム',
  'ソーセージ',
  'ベーコン',
];

var syubhahProduct = [
  '乳化剤',
  'マーガリン',
  'ショートニング',
];

var haramInfo = [
  {
    'japanese': '豚肉',
    'english': 'pork',
  },
  {
    'japanese': '牛肉',
    'english': 'beef',
  },
  {
    'japanese': '鶏肉',
    'english': 'chicken',
  },
  {
    'japanese': '清酒',
    'english': 'sake',
  },
  {
    'japanese': '洋酒',
    'english': 'western alcohol',
  },
  {
    'japanese': 'アルコール',
    'english': 'alcohol',
  },
  {
    'japanese': 'みりん',
    'english': 'rice wine',
  },
  {
    'japanese': 'ゼラチン',
    'english': 'gelatin',
  },
  {
    'japanese': 'チキン',
    'english': 'chicken',
  },
  {
    'japanese': 'ハム',
    'english': 'ham',
  },
  {
    'japanese': 'ソーセージ',
    'english': 'sausage',
  },
  {
    'japanese': 'ベーコン',
    'english': 'bacon',
  },
];

var syubhahInfo = [
  {
    'japanese': '乳化剤',
    'english': 'emulsifier',
  },
  {
    'japanese': 'マーガリン',
    'english': 'margarine',
  },
  {
    'japanese': 'ショートニング',
    'english': 'shortening',
  },
];

enum Detector { text, cloudText }

// Paints rectangles around all the text in the image.
class TextDetectorPainter extends CustomPainter {
  TextDetectorPainter(this.absoluteImageSize, this.visionText);

  final Size absoluteImageSize;
  final VisionText visionText;
  List<String> detectedHaramProduct = new List();
  List<String> detectedSyubhahProduct= new List();

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / absoluteImageSize.width;
    final double scaleY = size.height / absoluteImageSize.height;

    Rect scaleRect(TextContainer container) {
      return Rect.fromLTRB(
        container.boundingBox.left * scaleX,
        container.boundingBox.top * scaleY,
        container.boundingBox.right * scaleX,
        container.boundingBox.bottom * scaleY,
      );
    }

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        print(line.text);
        for (TextElement element in line.elements) {
          final String text = element.text;
          if (haramProduct.contains(text)) {
            detectedHaramProduct.add(text);
            paint.color = Colors.red;
            canvas.drawRect(scaleRect(element), paint);
          } else if (syubhahProduct.contains(text)) {
            detectedSyubhahProduct.add(text);
            paint.color = Colors.yellow;
            canvas.drawRect(scaleRect(element), paint);
          } else {
            paint.color = Colors.green;
            canvas.drawRect(scaleRect(element), paint);
          }
        }
      }

//        paint.color = Colors.yellow;
//        canvas.drawRect(scaleRect(line), paint);
    }

//      paint.color = Colors.red;
//      canvas.drawRect(scaleRect(block), paint);
  }

  List<String> getDetectedHaramProduct() => detectedHaramProduct;

  List<String> getDetectedSyubhahProduct() => detectedSyubhahProduct;

  @override
  bool shouldRepaint(TextDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.visionText != visionText;
  }
}

import 'package:flutter/material.dart';
import 'picture_service.dart';

class DescribeEnvironment extends StatelessWidget {
  final PictureService pictureService;

  DescribeEnvironment({required this.pictureService});

  @override
  Widget build(BuildContext context) {
    return pictureService.getCameraPreview();
  }
}
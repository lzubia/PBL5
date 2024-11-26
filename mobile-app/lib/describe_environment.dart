import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class DescribeEnvironment extends StatelessWidget {
  final CameraController cameraController;

  DescribeEnvironment({required this.cameraController});

  @override
  Widget build(BuildContext context) {
    return CameraPreview(cameraController);
  }
}
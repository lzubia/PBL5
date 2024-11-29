// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pbl5_menu/main.dart';

void main() {
  testWidgets('MyApp widget test', (WidgetTester tester) async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    await tester.pumpWidget(MyApp(camera: firstCamera));
    // Add your test cases here
  });
}

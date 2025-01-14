import 'package:flutter/material.dart';
import 'package:pbl5_menu/main.dart';
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'describe_environment.dart';
import '../services/picture_service.dart';
import 'package:pbl5_menu/features/money_identifier.dart';

const String describeEnvironmentTitle = 'Describe Environment';
const String gpsMapTitle = 'GPS (Map)';
const String moneyIdentifierTitle = 'Money Identifier';
const String scannerTitle = 'Scanner (Read Texts, QRs, ...)';

class GridMenu extends StatefulWidget {
  final PictureService pictureService;
  final dynamic ttsService;
  final String sessionToken;
  final GlobalKey<MoneyIdentifierState> moneyIdentifierKey;
  final GlobalKey<DescribeEnvironmentState> describeEnvironmentKey;
  final GlobalKey<OcrWidgetState> ocrWidgetKey;
  final GlobalKey<MapWidgetState> mapKey;

  const GridMenu({
    super.key,
    required this.pictureService,
    required this.ttsService,
    required this.sessionToken,
    required this.moneyIdentifierKey,
    required this.describeEnvironmentKey,
    required this.ocrWidgetKey,
    required this.mapKey,
  });

  @override
  GridMenuState createState() => GridMenuState();
}

class GridMenuState extends State<GridMenu> {
  bool isCameraInitialized = false;
  String? currentWidgetTitle;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    await widget.pictureService.initializeCamera();
    setState(() {
      isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    widget.pictureService.disposeCamera();
    super.dispose();
  }

  void showBottomSheet(BuildContext context, String title) {
    setState(() {
      currentWidgetTitle = title;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        enableDrag: false,
        showDragHandle: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildContent(title),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildContent(String title) {
    if (title == describeEnvironmentTitle) {
      return _buildDescribeEnvironmentContent();
    } else if (title == gpsMapTitle) {
      return _buildMapContent();
    } else if (title == moneyIdentifierTitle) {
      return _buildMoneyIdentifierContent();
    } else if (title == scannerTitle) {
      return _buildScannerContent();
    } else {
      return Text('Content for $title goes here.');
    }
  }

  Widget _buildDescribeEnvironmentContent() {
    if (isCameraInitialized) {
      return SizedBox(
        height: 550,
        child: DescribeEnvironment(
          key: widget.describeEnvironmentKey,
          pictureService: widget.pictureService,
          ttsService: widget.ttsService,
          sessionToken: widget.sessionToken,
        ),
      );
    } else {
      return const Center(
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget _buildScannerContent() {
    if (isCameraInitialized) {
      return SizedBox(
        height: 550,
        child: OcrWidget(
          key: widget.ocrWidgetKey,
          pictureService: widget.pictureService,
          ttsService: widget.ttsService,
          sessionToken: widget.sessionToken,
        ),
      );
    } else {
      return const Center(
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget _buildMapContent() {
    return SizedBox(
        height: 500,
        child: MapWidget(key: widget.mapKey, ttsService: widget.ttsService));
  }

  Widget _buildMoneyIdentifierContent() {
    return SizedBox(
      height: 550,
      child: MoneyIdentifier(
        key: widget.moneyIdentifierKey,
        pictureService: widget.pictureService,
        ttsService: widget.ttsService,
        sessionToken: widget.sessionToken,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuOptions = [
      {'title': describeEnvironmentTitle, 'icon': Icons.description},
      {'title': gpsMapTitle, 'icon': Icons.map},
      {'title': scannerTitle, 'icon': Icons.qr_code_scanner},
      {'title': moneyIdentifierTitle, 'icon': Icons.attach_money},
    ];

    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(menuOptions.length, (index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              showBottomSheet(context, menuOptions[index]['title']);
            },
            child: SizedBox(
              height: 150,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(menuOptions[index]['icon'], size: 50),
                    const SizedBox(height: 10),
                    Text(
                      menuOptions[index]['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

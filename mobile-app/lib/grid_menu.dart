import 'package:flutter/material.dart';
import 'package:pbl5_menu/map_widget.dart';
import 'describe_environment.dart';
import 'picture_service.dart';
import 'package:pbl5_menu/money_identifier.dart';

const String describeEnvironmentTitle = 'Describe Environment';
const String gpsMapTitle = 'GPS (Map)';
const String moneyIdentifierTitle = 'Money Identifier';

class GridMenu extends StatefulWidget {
  final PictureService pictureService;
  final dynamic ttsService;

  const GridMenu(
      {super.key, required this.pictureService, required this.ttsService});

  @override
  GridMenuState createState() => GridMenuState();
}

class GridMenuState extends State<GridMenu> {
  bool isCameraInitialized = false;

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

  void _showBottomSheet(BuildContext context, String title) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
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
    } else {
      return Text('Content for $title goes here.');
    }
  }

  Widget _buildDescribeEnvironmentContent() {
    if (isCameraInitialized) {
      return SizedBox(
        height: 550,
        child: DescribeEnvironment(
          pictureService: widget.pictureService,
          ttsService: widget.ttsService,
        ),
      );
    } else {
      return const Center(
        child: SizedBox(
          width: 50.0, // Adjust the width as needed
          height: 50.0, // Adjust the height as needed
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget _buildMapContent() {
    return const SizedBox(
      height: 500, // Adjust the height as needed to add whitespace
      child: MapWidget(),
    );
  }

  Widget _buildMoneyIdentifierContent() {
    return SizedBox(
      height: 550,
      child: MoneyIdentifier(
        pictureService: widget.pictureService,
        ttsService: widget.ttsService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuOptions = [
      {'title': describeEnvironmentTitle, 'icon': Icons.description},
      {'title': gpsMapTitle, 'icon': Icons.map},
      {
        'title': 'Scanner (Read Texts, QRs, ...)',
        'icon': Icons.qr_code_scanner
      },
      {'title': moneyIdentifierTitle, 'icon': Icons.attach_money},
    ];

    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(menuOptions.length, (index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              _showBottomSheet(context, menuOptions[index]['title']);
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

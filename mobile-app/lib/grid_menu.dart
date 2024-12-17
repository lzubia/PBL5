import 'package:flutter/material.dart';
import 'describe_environment.dart';
import 'picture_service.dart';

class GridMenu extends StatefulWidget {
  final PictureService pictureService;
  final dynamic ttsService;

  const GridMenu({super.key, required this.pictureService, required this.ttsService});

  @override
  _GridMenuState createState() => _GridMenuState();
}

class _GridMenuState extends State<GridMenu> {
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
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  if (title == 'Describe Environment' && isCameraInitialized)
                    Container(
                      height: 550,
                      child: DescribeEnvironment(
                          pictureService: widget.pictureService, ttsService: widget.ttsService,),
                    )
                  else if (title == 'Describe Environment' &&
                      !isCameraInitialized)
                    Center(child: CircularProgressIndicator()),
                  if (title == 'GPS (Map)')
                    Container(
                      height: 550,
                      //child: MapWidget(),
                    ),
                  if (title != 'Describe Environment' && title != 'GPS (Map)')
                    Text('Content for $title goes here.'),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuOptions = [
      {'title': 'Describe Environment', 'icon': Icons.description},
      {'title': 'GPS (Map)', 'icon': Icons.map},
      {
        'title': 'Scanner (Read Texts, QRs, ...)',
        'icon': Icons.qr_code_scanner
      },
      {'title': 'Money Identifier', 'icon': Icons.attach_money},
    ];

    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(menuOptions.length, (index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              _showBottomSheet(context, menuOptions[index]['title']);
            },
            child: Container(
              height: 150,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(menuOptions[index]['icon'], size: 50),
                    SizedBox(height: 10),
                    Text(
                      menuOptions[index]['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
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

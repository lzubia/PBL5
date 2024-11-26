import 'package:flutter/material.dart';

class GridMenu extends StatelessWidget {
  const GridMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuOptions = [
      {'title': 'Describe Environment', 'icon': Icons.description},
      {'title': 'GPS (Map)', 'icon': Icons.map},
      {'title': 'Scanner (Read Texts, QRs, ...)', 'icon': Icons.qr_code_scanner},
      {'title': 'Money Identifier', 'icon': Icons.attach_money},
    ];

    void _showBottomSheet(BuildContext context, String title) {
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
                  Text('Content for $title goes here.'),
                  // Add more content here as needed
                ],
              ),
            ),
          );
        },
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(menuOptions.length, (index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              _showBottomSheet(context, menuOptions[index]['title']);
            },
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
        );
      }),
    );
  }
}
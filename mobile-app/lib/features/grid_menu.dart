import 'package:flutter/material.dart';
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/widgetState_provider.dart';
import 'package:provider/provider.dart';
import 'describe_environment.dart';
import '../services/picture_service.dart';
import 'package:pbl5_menu/features/money_identifier.dart';
import 'voice_commands.dart'; // Import the VoiceCommands class

class GridMenu extends StatefulWidget {
  const GridMenu({super.key});

  @override
  GridMenuState createState() => GridMenuState();
}

class GridMenuState extends State<GridMenu> {
  bool isCameraInitialized = false;
  String? currentWidgetTitle;
  Widget? mapWidgetInstance;

  final double contentHeight = 550;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showBottomSheet(BuildContext context, String title) {
    final ttsService = context.read<ITtsService>();
    // Prevent showing multiple bottom sheets by ensuring state management
    if (currentWidgetTitle == title) {
      ttsService.speakLabels(['Widget already open']);
      return;
    }
    ;

    // Use addPostFrameCallback to delay setState until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        currentWidgetTitle = title; // Update the current widget title
      });

      // If it's not the first route and the widget is already open, close it
      if (!ModalRoute.of(context)!.isFirst &&
          (currentWidgetTitle != 'GPS (Map)' ||
              (currentWidgetTitle == 'GPS (Map)'))) {
        Navigator.of(context).pop();
      }

      // Show the bottom sheet with the corresponding content
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
      ).whenComplete(() {
        setState(() {
          currentWidgetTitle =
              null; // Reset the widget title after closing the bottom sheet
        });
      });
    });
  }

  Widget _buildContent(String title) {
    final contentMapping = {
      AppLocalizations.of(context).translate('describe_environment'):
          _buildDynamicWidget(DescribeEnvironment()),
      AppLocalizations.of(context).translate("gps_map"):
          _buildDynamicWidget(mapWidgetInstance ??= SizedBox(
        height: contentHeight,
        child: MapWidget(),
      )),
      AppLocalizations.of(context).translate("scanner"):
          _buildDynamicWidget(OcrWidget()),
      AppLocalizations.of(context).translate("money_identifier"):
          _buildDynamicWidget(MoneyIdentifier()),
    };

    return contentMapping[title] ?? Text('Content for $title goes here.');
  }

  Widget _buildDynamicWidget(Widget widgetContent) {
    final pictureService = context.read<PictureService>();
    if (pictureService.isCameraInitialized) {
      return SizedBox(height: contentHeight, child: widgetContent);
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

  @override
  Widget build(BuildContext context) {
    return Consumer2<WidgetStateProvider, VoiceCommands>(
      builder: (context, widgetStateProvider, voiceCommands, child) {
        // If triggerVariable is set, show the dynamic widget
        switch (voiceCommands.triggerVariable) {
          case 1:
            showBottomSheet(context,
                AppLocalizations.of(context).translate("money_identifier"));
            voiceCommands.triggerVariable = 0;
            break;
          case 2:
            showBottomSheet(
                context, AppLocalizations.of(context).translate("gps_map"));
            voiceCommands.triggerVariable = 0;
            break;
          case 3:
            showBottomSheet(context,
                AppLocalizations.of(context).translate("describe_environment"));
            voiceCommands.triggerVariable = 0;
            break;
          case 4:
            showBottomSheet(
                context, AppLocalizations.of(context).translate("scanner"));
            voiceCommands.triggerVariable = 0;
            break;
          default:
            break;
        }

        final List<Map<String, dynamic>> menuOptions = [
          {
            'title':
                AppLocalizations.of(context).translate('describe_environment'),
            'icon': Icons.description
          },
          {
            'title': AppLocalizations.of(context).translate('gps_map'),
            'icon': Icons.map
          },
          {
            'title': AppLocalizations.of(context).translate('scanner'),
            'icon': Icons.qr_code_scanner
          },
          {
            'title': AppLocalizations.of(context).translate('money_identifier'),
            'icon': Icons.attach_money
          },
        ];

        return GridView.count(
          crossAxisCount: 2,
          children: List.generate(menuOptions.length, (index) {
            final title = menuOptions[index]['title'];

            return Card(
              margin: const EdgeInsets.all(8.0),
              child: InkWell(
                onTap: () {
                  showBottomSheet(context, title);
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
      },
    );
  }
}

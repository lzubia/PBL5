import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pbl5_menu/features/map_widget.dart';
import 'package:pbl5_menu/features/ocr_widget.dart';
import 'package:pbl5_menu/map_provider.dart';
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/sos.dart';
import 'package:pbl5_menu/services/stt/i_tts_service.dart';
import 'package:pbl5_menu/shared/database_helper.dart';
import 'package:provider/provider.dart';
import 'describe_environment.dart';
import '../services/picture_service.dart';
import 'package:pbl5_menu/features/money_identifier.dart';
import 'voice_commands.dart';

class GridMenu extends StatefulWidget {
  const GridMenu({Key? key}) : super(key: key);

  @override
  GridMenuState createState() => GridMenuState();
}

class GridMenuState extends State<GridMenu> {
  bool isCameraInitialized = false;
  String? currentWidgetTitle; // To track the currently opened widget
  Widget? mapWidgetInstance; // Cache for the MapWidget instance

  final double contentHeight = 550;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Shows the bottom sheet with the selected widget
  void showBottomSheet(BuildContext context, String title) {
    final ttsService = context.read<ITtsService>();

    // Avoid showing duplicate bottom sheets
    if (currentWidgetTitle == title) {
      ttsService.speakLabels(
          [AppLocalizations.of(context).translate("opened")], context);
      return;
    } else if (currentWidgetTitle != null) {
      Navigator.of(context).pop(); // Close the previous bottom sheet
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        currentWidgetTitle = title; // Update the current widget title
      });

      if (title == AppLocalizations.of(context).translate("gps_map")) {
        // Register callback for `home_command` in MapWidget
        final voiceCommands =
            Provider.of<VoiceCommands>(context, listen: false);

        voiceCommands.onMapSearchHome = (LatLng latLng) {
          final mapProvider = Provider.of<MapProvider>(context, listen: false);

          mapProvider.setDestination(
            context: context,
            location: latLng, // Provide the `LatLng` object
          );
        };
      }

      // Show the bottom sheet with the corresponding widget
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
        // Reset the state when the bottom sheet is closed
        setState(() {
          currentWidgetTitle = null;
        });
      });
    });
  }

  /// Builds the content for the bottom sheet based on the selected widget title
  Widget _buildContent(String title) {
    final contentMapping = {
      AppLocalizations.of(context).translate('describe_environment'):
          _buildDynamicWidget(DescribeEnvironment()),
      AppLocalizations.of(context).translate("gps_map"):
          _buildDynamicWidget(mapWidgetInstance ??= SizedBox(
        height: contentHeight,
        child: MapWidget(title: 'guide'),
      )),
      AppLocalizations.of(context).translate("scanner"):
          _buildDynamicWidget(OcrWidget()),
      AppLocalizations.of(context).translate("money_identifier"):
          _buildDynamicWidget(MoneyIdentifier()),
    };

    return contentMapping[title] ?? Text('Content for $title goes here.');
  }

  /// Dynamically builds the widget content and handles camera initialization
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
    return Consumer<VoiceCommands>(
      builder: (context, voiceCommands, child) {
        // Set up callbacks for voice commands
        setupVoiceCommandCallbacks(context, voiceCommands);

        // Trigger bottom sheet if a command is activated
        handleBottomSheetTrigger(context, voiceCommands);

        // Define the grid menu options
        final List<Map<String, dynamic>> menuOptions =
            createMenuOptions(context);

        // Build the grid menu UI
        return GridView.count(
          crossAxisCount: 2,
          children: List.generate(menuOptions.length, (index) {
            return buildMenuCard(context, menuOptions[index]);
          }),
        );
      },
    );
  }

  void setupVoiceCommandCallbacks(
      BuildContext context, VoiceCommands voiceCommands) {
    voiceCommands.onMenuCommand = () {
      Navigator.of(context).popUntil((route) => route.isFirst); // Close all
    };

    voiceCommands.onSosCommand = () async {
      try {
        final sosService = Provider.of<SosService>(context, listen: false);
        final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);

        // Fetch contacts and send SOS request
        final contacts = await dbHelper.getContacts();
        await sosService.sendSosRequest(
            contacts.cast<Map<String, String>>(), context);
      } catch (e) {
        print('Error calling SOS service: $e');
      }
    };

    voiceCommands.onHomeCommand = () async {
      await handleHomeCommand(context);
    };
  }

  Future<void> handleHomeCommand(BuildContext context) async {
    try {
      final dbHelper = Provider.of<DatabaseHelper>(context, listen: false);
      final homeLocation = await dbHelper.getHomeLocation();

      final ttsService = Provider.of<ITtsService>(context, listen: false);

      if (homeLocation != null) {
        final mapProvider = Provider.of<MapProvider>(context, listen: false);

        // Set destination to home location
        await mapProvider.setDestination(
          context: context,
          location: homeLocation, // Provide the `LatLng` object
        );

        // Confirm with TTS
        await ttsService.speakLabels(
          [AppLocalizations.of(context).translate("going-home")],
          context,
        );
      } else {
        // Handle case when no home location is saved
        await ttsService.speakLabels(
          [AppLocalizations.of(context).translate("home-not-set")],
          context,
        );
      }
    } catch (e) {
      print('Error setting home destination: $e');
    }
  }

  void handleBottomSheetTrigger(
      BuildContext context, VoiceCommands voiceCommands) {
    if (voiceCommands.triggerVariable != 0) {
      final trigger = voiceCommands.triggerVariable;
      voiceCommands.triggerVariable = 0; // Reset the trigger immediately

      WidgetsBinding.instance.addPostFrameCallback((_) {
        switch (trigger) {
          case 1:
            showBottomSheet(context,
                AppLocalizations.of(context).translate("money_identifier"));
            break;
          case 2:
            showBottomSheet(
                context, AppLocalizations.of(context).translate("gps_map"));
            break;
          case 3:
            showBottomSheet(
                context, AppLocalizations.of(context).translate("scanner"));
            break;
          case 4:
            showBottomSheet(context,
                AppLocalizations.of(context).translate("describe_environment"));
            break;
          default:
            break;
        }
      });
    }
  }

  List<Map<String, dynamic>> createMenuOptions(BuildContext context) {
    return [
      {
        'title': AppLocalizations.of(context).translate('describe_environment'),
        'icon': Icons.description,
      },
      {
        'title': AppLocalizations.of(context).translate('gps_map'),
        'icon': Icons.map,
      },
      {
        'title': AppLocalizations.of(context).translate('scanner'),
        'icon': Icons.qr_code_scanner,
      },
      {
        'title': AppLocalizations.of(context).translate('money_identifier'),
        'icon': Icons.attach_money,
      },
    ];
  }

  Widget buildMenuCard(BuildContext context, Map<String, dynamic> option) {
    final ttsService = context.read<ITtsService>();
    final title = option['title'];
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          showBottomSheet(context, title);
        },
        onDoubleTap: () {
          ttsService.speakLabels(
            [AppLocalizations.of(context).translate(title)],
            context,
          );
        },
        child: SizedBox(
          height: 150,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(option['icon'], size: 100),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

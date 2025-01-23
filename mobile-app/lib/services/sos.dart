import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';

class SosService {
  final TtsServiceGoogle ttsServiceGoogle;
  final http.Client client; // Accept a custom client

  SosService({required this.ttsServiceGoogle, http.Client? client})
      : client = client ?? http.Client();

  Future<void> sendSosRequest(
      List<Map<String, String>> numbers, BuildContext context) async {
    final url = Uri.parse('https://begiapbl.duckdns.org:1880/sos');

    final response = await client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'numbers': numbers}),
    );

    if (response.statusCode == 200) {
      ttsServiceGoogle.speakLabels(
          [AppLocalizations.of(context).translate("Sos-sent-successfully")],
          context);
    } else {
      throw Exception('Failed to send SOS request');
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbl5_menu/services/l10n.dart';
import 'package:pbl5_menu/services/tts/tts_service_google.dart';

class SosService {
  TtsServiceGoogle ttsServiceGoogle;

  SosService({required this.ttsServiceGoogle});


  Future<void> sendSosRequest(List<Map<String, String>> numbers, BuildContext context) async {
    final url = Uri.parse('https://begiapbl.duckdns.org:1880/sos');

    // Aquí es donde ponemos el mapa como cuerpo del request
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'numbers': numbers}), // Agregar el mapa de números
    );

    if (response.statusCode == 200) {
      ttsServiceGoogle.speakLabels([AppLocalizations.of(context).translate("Sos-sent-successfully")]);
    } else {
      throw Exception('Failed to send SOS request');
    }
  }
}

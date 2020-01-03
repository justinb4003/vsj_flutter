import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class VSGData {
  static String gameUuid;
  static String playerUuid;
  static String playerName;
  static String gameLookupCode;
  static String _serverUrl = "http://192.168.1.128:5000";

  static Future<http.Response> getVSJUrl(String url) async {
    String fullUrl = VSGData._serverUrl + url;
    debugPrint(fullUrl);
    return http.get(fullUrl);
  }

  static Future<http.Response> postVSJUrl(String url, dynamic body) async {
    String fullUrl = VSGData._serverUrl + url;
    return http.post(fullUrl,
        headers: {HttpHeaders.contentTypeHeader: "application/json"},
        body: body);
  }

  static Future<int> loadPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    VSGData.playerName = prefs.getString('playerName') ?? '';
    debugPrint("loadPrefs() complete.");
    return 0;
  }
}

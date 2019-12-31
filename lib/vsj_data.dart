import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VSGData {
  static String game_uuid;
  static String game_lookup_code;
  static String _serverUrl = "http://192.168.1.128:5000";


  static Future<http.Response> getVSJUrl(String url) async {
    String fullUrl = VSGData._serverUrl + url;
    debugPrint(fullUrl);
    return http.get(fullUrl);
  }

}
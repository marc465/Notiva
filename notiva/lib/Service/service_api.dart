import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:notiva/start.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceAPI extends ChangeNotifier{
  late FlutterSecureStorage secureStorage;
  late SharedPreferences prefs;

  ServiceAPI();

  void init(FlutterSecureStorage storage, SharedPreferences pref) {
    secureStorage = storage;
    prefs = pref;
  }

  Future<int> handleRequest(Future<int> Function() request, BuildContext context) async {
    print("in service api");
    final statusCode = await request();
    print(statusCode);

    if (statusCode == 401) {
      bool refreshed = await refreshTokens();
      print(refreshed);
      if (!refreshed && context.mounted) {
        prefs.setBool('is_logged_out', true);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Start()),
          (route) => false,
        );
        return 401;
      }
      return await request();
    }
    return statusCode;
  }

  Future<bool> refreshTokens() async {
    print("in refresh tokens");
    final oldRefreshToken = await secureStorage.read(key: 'refresh_token');
    print(oldRefreshToken);
    
    if (oldRefreshToken == null) {
      return false;
    }

    final response = await http.get(
      Uri.parse("http://localhost:8080/refresh/tokens"),
      headers: {'Cookie': "refresh_token=$oldRefreshToken"},
    );

    print(response.statusCode);

    if (response.statusCode != 200) {
      return false;
    }

    final newRefreshToken = response.headers['set-cookie'];
    final newAccessToken = response.headers['access_token'];

    print(newAccessToken);
    print(newRefreshToken);

    if (newRefreshToken == null || newAccessToken == null) {
      return false;
    }

    await secureStorage.write(key: 'refresh_token', value: newRefreshToken);
    await secureStorage.write(key: 'access_token', value: newAccessToken);
    return true;
  }
}

class RefreshTokenExpired implements Exception {
  String cause = "Session expired. Please log in again.";
}

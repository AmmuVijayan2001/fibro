// ignore: file_names
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginApi {
  static Future<void> loginUser(
    BuildContext context,

    String email,
    String password, {
    required VoidCallback onSuccess,
    required Function(String errorMessage) onError,
  }) async {
    final url = Uri.parse(
      'https://backend.fiberonix.in/api/opticalfiber/login/',
    );

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        log(jsonEncode(data));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', data['token']);

        onSuccess();
      } else {
        onError(data['message']);
      }
    } catch (e) {
      onError('Error: $e');
      log("catch error :$e");
    }
  }
}

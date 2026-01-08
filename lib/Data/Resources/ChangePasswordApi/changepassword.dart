import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Data/Resources/TokenManage/tokenmanage.dart';

class ChangepasswordApi {
  static Future<bool> changePassword(
    BuildContext context,
    String oldPassword,
    String newPassword,
  ) async {
    final tokenmanager = TokenManager();
    final token = await tokenmanager.getToken();

    try {
      final response = await http.post(
        Uri.parse(
          'https://backend.fiberonix.in/api/opticalfiber/change/password/',
        ),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "$token",
        },
        body: jsonEncode({
          "old_password": oldPassword,
          "new_password": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        log(("Response Data: $responseData"));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        String message = "Failed to change password";
        try {
          final json = jsonDecode(response.body);
          message = json['message'] ?? message;
        } catch (_) {}
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      return false;
    }
  }
}

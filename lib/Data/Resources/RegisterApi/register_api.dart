// file: register_api.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterApi {
  static Future<void> registerUser(
    BuildContext context,
    String name,
    String registrationNumber,
    String email,
    String phone,
    String address,
    String adminName,
    String adminEmail,
    String adminPassword, {
    VoidCallback? onSuccess,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://backend.fiberonix.in/api/opticalfiber/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          "registration_number": registrationNumber,
          'email': email,
          "phone": phone,
          "address": address,
          "admin_name": adminName,
          "admin_email": adminEmail,
          "admin_password": adminPassword,
        }),
      );

      if (response.statusCode == 201) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registered successfully'),
            backgroundColor: Colors.green,
          ),
        );
        onSuccess?.call();
      } else {
        final json = jsonDecode(response.body);
        final message = json['message'] ?? 'Registration failed';
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

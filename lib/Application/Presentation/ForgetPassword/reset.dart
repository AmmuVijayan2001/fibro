// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Application/Presentation/Login%20Screen/loginscreen.dart';
import 'dart:convert';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';

// ignore: must_be_immutable
class ResetPassword extends StatefulWidget {
  String email;
  ResetPassword({super.key, required this.email});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpasswordcontroller =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _ispasswordvisible = false;
  bool _isconfirmpasswordvisible = false;

  bool isPasswordValid(String password) {
    final regex = RegExp(r'^(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$');
    return regex.hasMatch(password);
  }

  void _validatePassword() {
    if (_formKey.currentState!.validate()) {
      _changePassword();
    }
  }

  Future<void> _changePassword() async {
    String newPassword = _passwordController.text;

    final String url =
        'http://103.134.134.14:8000/api/opticalfiber/reset/password/';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"email": widget.email, 'new_password': newPassword}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("password changed successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      } else {
        final responseData = json.decode(response.body);
        log("reset password err:${responseData['message']['message']}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${responseData['message']['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      log("catch error reset password: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change password. Try again later.')),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _ispasswordvisible = !_ispasswordvisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isconfirmpasswordvisible = !_isconfirmpasswordvisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(30),
                offset: Offset(0, 2),
                blurRadius: 6,
                spreadRadius: 2,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios_new, color: appClr),
            ),
            title: Text("CHANGE PASSWORD"),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "New Password",
                                style: TextStyle(
                                  color: appClr,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_ispasswordvisible,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: _togglePasswordVisibility,
                                icon:
                                    _ispasswordvisible
                                        ? const Icon(Icons.visibility_off)
                                        : const Icon(Icons.visibility),
                              ),
                              labelText: "Password",
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black38),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter password";
                              }
                              if (!isPasswordValid(value)) {
                                return "Password must be at least 8 characters and contain one special character";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                "Confirm Password",
                                style: TextStyle(
                                  color: appClr,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: _confirmpasswordcontroller,
                            obscureText: !_isconfirmpasswordvisible,
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: _toggleConfirmPasswordVisibility,
                                icon:
                                    _isconfirmpasswordvisible
                                        ? const Icon(Icons.visibility_off)
                                        : const Icon(Icons.visibility),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black38),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.black),
                              ),
                              labelText: "Confirm Password",
                              labelStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Confirm your password";
                              }
                              if (value != _passwordController.text) {
                                return "Passwords do not match";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: BeveledRectangleBorder(),
                              backgroundColor: appClr,
                              minimumSize: Size(200, 40),
                            ),
                            onPressed: () {
                              _validatePassword();
                            },
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

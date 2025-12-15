import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:network_mapping_app/Application/Presentation/ForgetPassword/otpverify.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';

class EmailVerify extends StatefulWidget {
  const EmailVerify({super.key});

  @override
  State<EmailVerify> createState() => _EmailVerifyState();
}

class _EmailVerifyState extends State<EmailVerify> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _emailver() async {
    final String url =
        "https://backend.fiberonix.in/api/opticalfiber/forgot/password/";

    try {
      final response = await http.post(Uri.parse(url));
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerify(email: emailController.text),
          ),
        );
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody["message"]),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // ignore: avoid_print
        print(responseBody["message"]);
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody["message"] ?? "Something went wrong"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log("atch error:$e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: AppBar(backgroundColor: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Enter your registered email to reset password",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45),
                  ),
                  labelText: "Email",
                  hintText: "Enter your email",
                  suffixIcon: Icon(Icons.email, color: appClr),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Email is required";
                  } else if (!RegExp(
                    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                  ).hasMatch(value)) {
                    return "Enter a valid email address";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Perform password reset action
                    _emailver();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appClr,
                  minimumSize: Size(150, 40),
                  shape: BeveledRectangleBorder(),
                ),
                child: Text(
                  "Sent Otp",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

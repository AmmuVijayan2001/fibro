// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:network_mapping_app/Application/Presentation/ForgetPassword/reset.dart';

class OTPVerify extends StatefulWidget {
  String email;
  OTPVerify({super.key, required this.email});

  @override
  State<OTPVerify> createState() => _OTPVerifyState();
}

class _OTPVerifyState extends State<OTPVerify> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  bool isTimerFinished = false;
  int timerSeconds = 60; // Set countdown time

  Future<void> verOtp(String pin) async {
    final url = "https://backend.fiberonix.in/api/opticalfiber/verify/otp/";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
        body: {"email": widget.email, "otp": pin.toString()},
      );
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        print("Outut :$responseBody");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPassword(email: widget.email),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody["message"] ?? "OTP Verified"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print(responseBody["message"]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody["message"] ?? "Something went wrong"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("catch error:$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _resendOtp() async {
    final String url = "https://backend.fiberonix.in/api/forgot/password/";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {"Accept": "application/json"},
        body: {"email": widget.email},
      );
      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        setState(() {
          isTimerFinished = false; // Reset timer state
          _pinPutController.clear(); // Clear OTP field
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody["message"]),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print(responseBody["message"]);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(responseBody["message"] ?? "Something went wrong"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("atch error:$e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // void resendOTP() {
  //   setState(() {
  //     isTimerFinished = false; // Reset timer state
  //     _pinPutController.clear(); // Clear OTP field
  //   });
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("OTP Resent"), backgroundColor: Colors.blue),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(fontSize: 20, color: Colors.black),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey),
      ),
    );

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
            title: Text(
              "OTP Verification",
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontFamily: "times",
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter the 6-digit code sent to your email.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 30),
              Pinput(
                controller: _pinPutController,
                focusNode: _pinPutFocusNode,
                length: 6,
                onCompleted: (pin) => verOtp(pin),
                defaultPinTheme: defaultPinTheme,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return "Enter a valid 6-digit OTP";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TimerCountdown(
                format: CountDownTimerFormat.secondsOnly,
                endTime: DateTime.now().add(Duration(seconds: timerSeconds)),
                onEnd: () {
                  setState(() {
                    isTimerFinished = true;
                  });
                },
                timeTextStyle: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    verOtp(_pinPutController.text);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(150, 40),
                  shape: BeveledRectangleBorder(),
                ),
                child: Text(
                  "Verify OTP",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: isTimerFinished ? _resendOtp : null,
                child: Text(
                  "Resend OTP",
                  style: TextStyle(
                    color: isTimerFinished ? Colors.blue : Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

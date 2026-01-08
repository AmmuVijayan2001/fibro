import 'package:flutter/material.dart';
import 'package:network_mapping_app/Application/Presentation/Login%20Screen/loginscreen.dart';
import 'package:network_mapping_app/Application/Presentation/ProfileScreen/profilescreen.dart';
import 'package:network_mapping_app/Data/Resources/RegisterApi/register_api.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';

class RegistrationScreen extends StatefulWidget {
  final String companyName;
  final String registrationNum;
  final String companyEmail;
  final String phone;
  final String address;

  const RegistrationScreen({
    required this.companyName,
    required this.registrationNum,
    required this.companyEmail,
    required this.phone,
    required this.address,
    Key? key,
  }) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  bool isPasswordVisible = false;
  final TextEditingController adminNameController = TextEditingController();
  final TextEditingController adminEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'^(?=.*[!@#\$&*~])').hasMatch(value)) {
      return 'Must contain at least one special character';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            ClipPath(
              clipper: WaveClipper(),
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: appClr,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage("asset/images/2254327.jpg"),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 350),
                    TextFormField(
                      controller: adminNameController,
                      decoration: InputDecoration(
                        labelText: 'Admin Name*',
                        prefixIcon: const Icon(Icons.business),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Admin name is required'
                                  : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: adminEmailController,
                      decoration: InputDecoration(
                        labelText: 'Admin Email*',
                        prefixIcon: const Icon(Icons.mail),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password*',
                        prefixIcon: const Icon(Icons.password),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.brown,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.brown),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appClr,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            RegisterApi.registerUser(
                              context,
                              widget.companyName,
                              widget.registrationNum,
                              widget.companyEmail,
                              widget.phone,
                              widget.address,
                              adminNameController.text,
                              adminEmailController.text,
                              passwordController.text,
                              onSuccess: () {
                                adminNameController.clear();
                                adminEmailController.clear();
                                passwordController.clear();

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                            );
                          }
                        },
                        child: const Text(
                          'Register',
                          style: TextStyle(fontSize: 18, color: whiteClr),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

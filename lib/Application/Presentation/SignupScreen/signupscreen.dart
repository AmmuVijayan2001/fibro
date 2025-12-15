import 'package:flutter/material.dart';
import 'package:network_mapping_app/Application/Presentation/ProfileScreen/profilescreen.dart';
import 'package:network_mapping_app/Application/Presentation/SignupScreen/finalsignupscreen.dart';
import 'package:network_mapping_app/Domine/Core/Constant/constant.dart';

class Signupscreen extends StatefulWidget {
  const Signupscreen({Key? key}) : super(key: key);

  @override
  State<Signupscreen> createState() => _SignupscreenState();
}

class _SignupscreenState extends State<Signupscreen> {
  final _formKey = GlobalKey<FormState>();
  bool isFormFilled = false;

  final companyNameController = TextEditingController();
  final regNumController = TextEditingController();
  final companyEmailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    companyNameController.addListener(_checkFields);
    regNumController.addListener(_checkFields);
    companyEmailController.addListener(_checkFields);
    phoneController.addListener(_checkFields);
    addressController.addListener(_checkFields);
  }

  void _checkFields() {
    setState(() {
      isFormFilled =
          companyNameController.text.isNotEmpty &&
          regNumController.text.isNotEmpty &&
          companyEmailController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          addressController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    companyNameController.dispose();
    regNumController.dispose();
    companyEmailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isFormFilled ? appClr : Colors.grey,
        onPressed: () {
          if (_formKey.currentState?.validate() ?? false) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder:
                    (context) => RegistrationScreen(
                      companyName: companyNameController.text,
                      registrationNum: regNumController.text,
                      companyEmail: companyEmailController.text,
                      phone: phoneController.text,
                      address: addressController.text,
                    ),
              ),
            );
          }
        },
        label: const Text('Continue', style: TextStyle(color: whiteClr)),
        icon: const Icon(Icons.arrow_forward, color: whiteClr),
      ),
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
                    const SizedBox(height: 310),
                    const Text(
                      "Company Registration",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Hi! Create Your Account',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: greyClr,
                      ),
                    ),
                    const SizedBox(height: 32),

                    TextFormField(
                      controller: companyNameController,
                      decoration: _inputDecoration(
                        'Company Name*',
                        Icons.business,
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Company name is required'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: regNumController,
                      decoration: _inputDecoration(
                        'Registration Number*',
                        Icons.badge,
                      ),
                      keyboardType: TextInputType.number,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Registration number is required'
                                  : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: companyEmailController,
                      decoration: _inputDecoration(
                        'Company Email*',
                        Icons.mail,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: phoneController,
                      decoration: _inputDecoration(
                        'Phone Number*',
                        Icons.phone,
                      ),
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: addressController,
                      decoration: _inputDecoration(
                        'Address*',
                        Icons.location_on,
                      ),
                      keyboardType: TextInputType.streetAddress,
                      maxLines: null,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Address is required'
                                  : null,
                    ),
                    const SizedBox(height: 80),
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

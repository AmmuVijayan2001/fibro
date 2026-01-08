import 'package:flutter/material.dart';

class Privacypolicyscreen extends StatelessWidget {
  const Privacypolicyscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Privacy Policy",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 8),
                      Text(
                        "Outline Kerala",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Privacy Policy",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),

                _sectionTitle("1. Information We Collect"),
                _sectionText(
                  "• Name & Email (used for login and personalization)\n"
                  "• App usage data (to improve recommendations)\n"
                  "• Device details (to enhance app performance)",
                ),

                _sectionTitle("2. How We Use Your Data"),
                _sectionText(
                  "• Provide news and live TV streaming.\n"
                  "• Personalize your app experience.\n"
                  "• Notify you about updates.",
                ),

                _sectionTitle("3. Data Sharing"),
                _sectionText(
                  "We never sell or share your data with third parties except for essential services.",
                ),

                _sectionTitle("4. Security"),
                _sectionText(
                  "We take necessary measures to protect your data but cannot guarantee absolute security.",
                ),

                _sectionTitle("5. Third-Party Services"),
                _sectionText(
                  "Our app may link to other sites; we are not responsible for their privacy practices.",
                ),

                _sectionTitle("6. Your Rights"),
                _sectionText(
                  "You can request data deletion anytime by contacting us at:\n📧 outlinekerala@gmail.com",
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Last updated: August 2025",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widgets for cleaner code
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _sectionText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
    );
  }
}

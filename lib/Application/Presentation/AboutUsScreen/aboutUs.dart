import 'package:flutter/material.dart';

class Aboutusscreen extends StatelessWidget {
  const Aboutusscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "About Us",
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
                      const Text(
                        "Outline Kerala",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Stay Updated. Stay Informed.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                _sectionTitle("Our Mission"),
                _sectionText(
                  "Outline Kerala is a modern news app dedicated to bringing you the latest headlines, live updates, and breaking stories from across Kerala and beyond. We believe in fast, unbiased, and clean journalism at your fingertips.",
                ),

                _sectionTitle("Features"),
                _sectionText(
                  "• Read trending, latest, and category-based news.\n"
                  "• Watch Live TV streams from within the app.\n"
                  "• Access rich multimedia news content.\n"
                  "• Smooth and lightweight app design.\n"
                  "• Fast updates and clean user experience.",
                ),

                _sectionTitle("Why Choose Us?"),
                _sectionText(
                  "We combine traditional news coverage with real-time streaming, creating a unique and immersive experience for our readers. Whether you're at home or on the move, stay connected with the latest from Kerala.",
                ),

                _sectionTitle("Contact Us"),
                _sectionText(
                  "If you have feedback, suggestions, or business inquiries, feel free to reach out:\n"
                  "📧 Email: outlinekerala@gmail.com\n"
                  "📍 Location: Kochi, Kerala",
                ),

                const SizedBox(height: 20),
                Center(
                  child: Text(
                    "Version 1.0.0 • August 2025",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Reusable section title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Reusable section text
  Widget _sectionText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
    );
  }
}

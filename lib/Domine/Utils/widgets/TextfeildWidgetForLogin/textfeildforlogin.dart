import 'package:flutter/material.dart';

class Textfeildwidget extends StatelessWidget {
  const Textfeildwidget({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.prefixIcon,
    this.maxLength,
    this.maxLines,
    required this.controller,
    required String? Function(dynamic value) validator,
    this.keyboardType,
  });

  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final int? maxLength;
  final int? maxLines;
  final TextInputType? keyboardType;

  final TextEditingController controller;
  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: keyboardType,
      controller: controller,
      maxLength: maxLength,
      maxLines: maxLines,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        hintText: hintText,
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}

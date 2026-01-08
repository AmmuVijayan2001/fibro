import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextwidget extends StatelessWidget {
  // ignore: use_super_parameters
  const AppTextwidget({
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    this.softWrap,
    this.overflow,
    final int? maxLines,

    Key? key,
  }) : super(key: key);

  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final bool? softWrap;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      overflow: overflow,
      softWrap: softWrap,
      text,
      style: GoogleFonts.poppins(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }
}

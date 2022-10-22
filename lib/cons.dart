import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color black = Color(0xFF262626);
const Color white = Colors.white;
final Color primary = Colors.blue.shade800;
const Color tealBlue = Color(0xFF043b5c);

ThemeData lightTheme() {
  return ThemeData(
    primaryColor: primary,
    iconTheme: const IconThemeData(size: 18),
    cardColor: white,
    textTheme: TextTheme(
        bodyText1: GoogleFonts.poppins().copyWith(color: black, fontSize: 12)),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all(
            GoogleFonts.poppins().copyWith(color: white, fontSize: 12)),
        foregroundColor: MaterialStateProperty.all(black),
        backgroundColor: MaterialStateProperty.all(white),
      ),
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    primaryColor: black,
    iconTheme: const IconThemeData(size: 18),
    textTheme: TextTheme(
        bodyText1: GoogleFonts.poppins().copyWith(color: white, fontSize: 12)),
    cardColor: tealBlue,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(white),
        textStyle: MaterialStateProperty.all(
            GoogleFonts.poppins().copyWith(color: white, fontSize: 12)),
        backgroundColor: MaterialStateProperty.all(tealBlue),
      ),
    ),
  );
}

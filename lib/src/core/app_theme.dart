import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple, 
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.latoTextTheme( 
        ThemeData.light().textTheme,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.deepPurple.shade100, 
        titleTextStyle: GoogleFonts.lato( 
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple, 
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.latoTextTheme(
        ThemeData.dark().textTheme,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.deepPurple.shade900,
        titleTextStyle: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white70),
      ),
    );
  }
}
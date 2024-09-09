import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Widgets/login_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generator Paybill',
      theme: ThemeData(
        textTheme: GoogleFonts.almaraiTextTheme(
          Theme.of(context)
              .textTheme
              .apply(bodyColor: Colors.teal, displayColor: Colors.teal),
        ),
        primarySwatch: Colors.teal,
      ),
      home: const MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

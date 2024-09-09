// import 'dart:ffi';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:generators/Widgets/login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Adjust the import according to your project structure

class UserInfoPage extends StatelessWidget {
  final String token;
  final String username;
  final String displayName;
  final String phone;
  final String province;
  final String districtName;
  final String role;
  const UserInfoPage({
    super.key,
    required this.token,
    required this.username,
    required this.displayName,
    required this.phone,
    required this.province,
    required this.districtName,
    required this.role,
  });

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('isLoggedIn');
    await prefs.remove('username');
    await prefs.remove('displayName');
    await prefs.remove('phone');
    await prefs.remove('district');
    await prefs.remove('districtCouncilId');
    await prefs.remove('province');
    await prefs.remove('provincialCouncilId');
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainPage(), // Adjust to your main page
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "معلومات المستخدم",
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "اسم المستخدم: ${displayName}",
              style: GoogleFonts.almarai(fontSize: 20),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () => _logout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const ui.Size(double.infinity, 36),
              ),
              child: Text(
                'تسجيل الخروج',
                style: GoogleFonts.almarai(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:generators/Widgets/homepagewidget.dart';
import 'package:generators/screens/owner/gen_admin_home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'reser_password.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  final TextEditingController _loginPhoneController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  final TextEditingController _registerPhoneController =
      TextEditingController();
  final TextEditingController _registerPasswordController =
      TextEditingController();
  final TextEditingController _rewritePasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nationalId = TextEditingController();

  int _selectedIndex = 0;
  final baseUrl = 'https://localhost:7046/api/';

  void _login() async {
    String? userName = _loginPhoneController.text.trim();
    String? password = _loginPasswordController.text.trim();

    if (userName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال اسم المستخدم.')),
      );
      return;
    } else if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال كلمة المرور.')),
      );
      return;
    }
    try {
      HttpClient httpClient = HttpClient();
      HttpClientRequest request =
          await httpClient.postUrl(Uri.parse('${baseUrl}login'));

      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      request.headers.set('Accept', 'application/json');

      String body = 'username=$userName&password=$password';
      request.write(body);

      HttpClientResponse response = await request.close();
      if (kDebugMode) {
        print(response.statusCode);
      }

      if (response.statusCode == 200) {
        String responseBody = await response.transform(utf8.decoder).join();
        final responseData = json.decode(responseBody);
        final String token = responseData['token'];
        final user = responseData['user'];
        final String? username = user?['user_name'] ?? 'Unknown';
        final String? displayname = user?['display_name'] ?? 'Unknown';
        final String? phone = user?['phone'] ?? 'Unknown';
        final String? districtName = user?['district']?['name'] ?? 'Unknown';
        final String? role = user?['role']?['name'] ?? 'Unknown';
        final String? province = user?['province']?['name'] ?? 'Unknown';
        if (kDebugMode) {
          print(token);
          print(user);
          print(role);
          print(province);
          print(districtName);
          print(phone);
          print(username);
        }

        // Navigate to HomePage
        if (role == 'GeneratorAdmin') {
          // Navigate to SubscriptionsPage for GeneratorAdmin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SubscriptionsAdminPage(
                token: token,
                username: username!,
                displayname: displayname!,
                phone: phone!,
                districtName: districtName!,
                province: province!,
                role: role!,
              ),
            ),
          );
        } else {
          // Navigate to HomePage for other roles
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(
                token: token,
                username: username,
                displayname: displayname,
                phone: phone,
                districtName: districtName,
                province: province,
                role: role,
              ),
            ),
          );
        }
      } else {
        String responseBody = await response.transform(utf8.decoder).join();
        print("Login failed: $responseBody");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('فشل تسجيل الدخول , الرجاء التسجيل مرة اخرى .')),
        );
      }

      httpClient.close();
    } catch (e) {
      print("Error during login: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred. Please try again.')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      String? token = prefs.getString('token');
      String? username = prefs.getString('username');
      String? displayname = prefs.getString('displayname');
      String? phone = prefs.getString('phone');
      String? districtName = prefs.getString('districtName');
      String? province = prefs.getString('province');
      String? role = prefs.getString('role');

      if (token != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              token: token,
              username: username,
              phone: phone,
              displayname: displayname,
              districtName: districtName,
              province: province,
              role: role,
            ),
          ),
        );
      }
    }
  }

  void _register() async {
    // Add the HTTP POST request
    if (_registerFormKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('${baseUrl}register'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'phone': _registerPhoneController.text,
          'password': _registerPasswordController.text,
          'fullname': _fullNameController.text,
          'address': _addressController.text,
          'role': 'User',
          'role_id': '5',
          'national_id': _nationalId.text,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final String token = responseData['token'];
        final user = responseData['user'];
        final String username = user['username'];
        final String displayname = user['display_name'];
        final String phone = user['phone'];
        final district = user['district'];
        final String districtName = district['name'];
        final String role = 'User';
        final String province = user['province']['name'];

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(
                    token: token,
                    username: username,
                    phone: phone,
                    displayname: displayname,
                    districtName: districtName,
                    province: province,
                    role: role,
                  )),
        );
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('فشل تسجيل الحساب , الرجاء التسجيل فيما بعد')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 255, 255, 255)
                ], // Two colors for the gradient
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          Column(
            children: [
              BottomNavyBar(
                selectedIndex: _selectedIndex,
                showElevation: true,
                onItemSelected: (index) => setState(() {
                  _selectedIndex = index;
                }),
                items: [
                  BottomNavyBarItem(
                    icon:
                        Icon(Icons.login, size: _selectedIndex == 0 ? 20 : 20),
                    title: _selectedIndex == 0
                        ? const Text('تسجيل الدخول',
                            style: TextStyle(fontSize: 10))
                        : const SizedBox.shrink(),
                    activeColor: Colors.teal,
                    textAlign: TextAlign.center,
                  ),
                  BottomNavyBarItem(
                    icon: Icon(Icons.app_registration,
                        size: _selectedIndex == 1 ? 24 : 20),
                    title: _selectedIndex == 1
                        ? const Text(
                            'التسجيل',
                            style: TextStyle(fontSize: 12),
                          )
                        : const SizedBox.shrink(),
                    activeColor: Colors.teal,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SingleChildScrollView(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0, vertical: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: _selectedIndex == 0
                              ? _buildLoginForm()
                              : _buildRegistrationForm(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _loginPhoneController,
            decoration: InputDecoration(
              labelText: 'الرقم الهاتف ',
              labelStyle: TextStyle(fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: const Icon(Icons.phone),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.almarai(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return ' الرجاء ادخال رقم الهاتف';
              }

              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _loginPasswordController,
            decoration: InputDecoration(
              labelText: 'كلمة المرور',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: const Icon(Icons.lock),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            obscureText: true,
            style: GoogleFonts.almarai(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء ادخال كلمة المرور';
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.teal,
              minimumSize: const Size(double.infinity, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15.0),
            ),
            child: Text(
              'تسجيل الدخول',
              style: GoogleFonts.cairo(
                textStyle: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12.0),
          TextButton(
            onPressed: _resetPassword,
            child: Text(
              'هل نسيت كلمة المرور؟',
              style: GoogleFonts.cairo(
                textStyle: TextStyle(
                  color: Colors.teal,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetPassword() {
    // Navigate to ResetPasswordPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResetPasswordPage(),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              labelText: 'الاسم الكامل',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: const Icon(Icons.person),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.almarai(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء ادخال الاسم الكامل';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _registerPhoneController,
            decoration: InputDecoration(
              labelText: 'رقم الهاتف',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: const Icon(Icons.phone),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.almarai(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء ادخال رقم الهاتف';
              }
              if (!RegExp(r'^0\d{10}$').hasMatch(value)) {
                return 'الرجاء ادخال رقم هاتف صحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _registerPasswordController,
            decoration: InputDecoration(
              labelText: 'كلمة السر',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: const Icon(Icons.lock),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            obscureText: true,
            style: GoogleFonts.almarai(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء ادخال كلمة السر';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _rewritePasswordController,
            decoration: InputDecoration(
              labelText: 'أعد كتابة كلمة السر',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: const Icon(Icons.lock),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            obscureText: true,
            style: GoogleFonts.almarai(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال كلمة السر مرة أخرى';
              }
              if (value != _registerPasswordController.text) {
                return 'كلمات السر غير متطابقة';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'العنوان',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: const Icon(Icons.location_on),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: GoogleFonts.almarai(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء ادخال العنوان';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _nationalId,
            decoration: InputDecoration(
              labelText: 'رقم البطاقة الموحدة',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: const Icon(Icons.numbers),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            style: GoogleFonts.almarai(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء ادخال رقم البطاقة الموحدة';
              }
              if (RegExp(r'^\d{12}$').hasMatch(value)) {
                return 'الرجاء ادخال رقم البطاقة الصحيح';
              }
              return null;
            },
          ),
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _register,
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.teal,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15.0),
            ),
            child: Text(
              'التسجيل',
              style: GoogleFonts.cairo(
                textStyle: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

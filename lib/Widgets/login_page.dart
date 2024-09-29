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
  bool _isLoading = true;
  List<Map<String, dynamic>> _provinces = [];
  List<Map<String, dynamic>> _districts = [];
  String? _selectedProvince;
  String? _selectedDistrict;
  List<String> _generatorIds = [];

  Future<void> _fetchproviance() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://apigenerators.sooqgate.com/api/getlistprovinces'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _provinces = data.cast<Map<String, dynamic>>();
          _generatorIds = _provinces
              .map((province) => province['provincial_council_id'].toString())
              .toList();
          _selectedProvince =
              _generatorIds.isNotEmpty ? _generatorIds[0] : null;
        });
      } else {
        print('Failed to fetch provinces: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch provinces. Please try again.')),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchDistricts(String provinceId) async {
    final url =
        'https://apigenerators.sooqgate.com/api/getlistdistricts/$provinceId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> districtData =
            json.decode(response.body); // Directly decode to a list

        _districts.clear(); // Clear previous districts
        _districts.addAll(districtData.map((district) {
          return {
            'district_council_id': district['district_council_id']
                .toString(), // Ensure 'district_id' is a string
            'name': district['name'],
          };
        }).toList());

        setState(() {
          _selectedDistrict = null; // Reset selected district
        });
      } else {
        throw Exception('Failed to load districts');
      }
    } catch (e) {
      print('Error fetching districts: $e'); // Debugging
      // Handle errors appropriately
    }
  }

  int _selectedIndex = 0;
  final baseUrl = 'https://apigenerators.sooqgate.com/api/';

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
        final int userId = user?['id'];
        final String? username = user?['user_name'] ?? 'Unknown';
        final String? displayname = user?['display_name'] ?? 'Unknown';
        final String? phone = user?['phone'] ?? 'Unknown';
        final String? districtName = user?['district']?['name'] ?? 'Unknown';
        final String? role = user?['role']?['name'] ?? 'Unknown';
        final String? province = user?['province']?['name'] ?? 'Unknown';
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('token', token);
        await prefs.setString('username', username!);
        await prefs.setString('displayname', displayname!);
        await prefs.setString('phone', phone!);
        await prefs.setString('districtName', districtName!);
        await prefs.setString('province', province!);
        await prefs.setString('role', role!);
        await prefs.setInt('userId', userId);
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
                username: username,
                userId: userId,
                displayname: displayname,
                phone: phone,
                districtName: districtName,
                province: province,
                role: role,
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
                userId: userId,
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
    _fetchproviance();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    setState(() {
      _isLoading = false; // Stop loading after checking
    });
    if (isLoggedIn) {
      String? token = prefs.getString('token');
      String? username = prefs.getString('username');
      String? displayname = prefs.getString('displayname');
      String? phone = prefs.getString('phone');
      String? districtName = prefs.getString('districtName');
      String? province = prefs.getString('province');
      String? role = prefs.getString('role');
      int userId = prefs.getInt('userId') ?? 0;

      if (token != null) {
        if (role == 'GeneratorAdmin') {
          // Navigate to SubscriptionsPage for GeneratorAdmin
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SubscriptionsAdminPage(
                token: token,
                username: username!,
                userId: userId,
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
                userId: userId,
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
        final userId = user['id'];

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
                    userId: userId,
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
      body: _isLoading // Show loading indicator if checking status
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Background Gradient
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 255, 255, 255),
                        Color.fromARGB(255, 255, 255, 255)
                      ],
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
                          icon: Icon(Icons.login,
                              size: _selectedIndex == 0 ? 24 : 20),
                          title: _selectedIndex == 0
                              ? const Text('تسجيل الدخول',
                                  style: TextStyle(fontSize: 16))
                              : const SizedBox.shrink(),
                          activeColor: Colors.teal,
                          textAlign: TextAlign.center,
                        ),
                        BottomNavyBarItem(
                          icon: Icon(Icons.app_registration,
                              size: _selectedIndex == 1 ? 24 : 20),
                          title: _selectedIndex == 1
                              ? const Text('التسجيل',
                                  style: TextStyle(fontSize: 16))
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
            onPressed: _isLoading ? null : _login,
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
          DropdownButtonFormField<String>(
            value: _selectedProvince,
            hint: Text(
              'اختر المحافظة',
              style: GoogleFonts.almarai(),
            ),
            items: _provinces.map((province) {
              return DropdownMenuItem<String>(
                value: province['provincial_council_id'].toString(),
                child: Text(
                  '${province['name']}',
                  style:
                      GoogleFonts.almarai().copyWith(color: Colors.grey[700]),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedProvince = value;
                _districts.clear();
                _fetchDistricts(
                    value!); // Fetch districts when province is selected
              });
            },
            validator: (value) {
              if (value == null) {
                return 'يرجى اختيار المحافظة';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'اختر المحافظة',
              prefixIcon: Icon(Icons.electrical_services),
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: GoogleFonts.almarai(),
          ),
          SizedBox(height: 20), // Spacing between dropdowns

          // Dropdown for Districts
          DropdownButtonFormField<String>(
            value: _selectedDistrict,
            hint: Text(
              'اختر المدينة',
              style: GoogleFonts.almarai(),
            ),
            items: _districts.map((district) {
              return DropdownMenuItem<String>(
                value: district['district_council_id'],
                child: Text(
                  district['name'],
                  style:
                      GoogleFonts.almarai().copyWith(color: Colors.grey[700]),
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDistrict = value; // Update selected district
              });
            },
            validator: (value) {
              if (value == null) {
                return 'يرجى اختيار المدينة';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'اختر المدينة',
              prefixIcon: Icon(Icons.location_city),
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: GoogleFonts.almarai(),
          ),
          SizedBox(height: 20), // Spacing between dropdowns
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _isLoading ? null : _register,
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

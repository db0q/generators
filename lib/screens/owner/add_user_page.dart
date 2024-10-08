import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'search_user.dart';

class AddUserPage extends StatefulWidget {
  final String token;
  final String districtName;
  final String province;

  const AddUserPage({
    super.key,
    required this.token,
    required this.districtName,
    required this.province,
  });

  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ampController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<Map<String, dynamic>> _generators = [];
  List<String> _generatorIds = [];
  String? _selectedGeneratorId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchGeneratorIds();
  }

  Future<void> _fetchGeneratorIds() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://apigenerators.sooqgate.com/api/gens'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          _generators = data.cast<Map<String, dynamic>>();
          if (_generators.isNotEmpty) {
            _generatorIds = _generators
                .map((gen) => gen['electric_generator_id'].toString())
                .toList();
            _selectedGeneratorId =
                _generatorIds.isNotEmpty ? _generatorIds[0] : null;
          } else {
            _generatorIds = [];
            _selectedGeneratorId = null;
          }
        });
      } else {
        print('Failed to fetch generator IDs: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedGeneratorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يرجى اختيار معرف المولد.'),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      final Map<String, String> body = {
        'displayName': _displayNameController.text,
        'name': _displayNameController.text,
        'phone': _phoneController.text,
        'amp': _ampController.text,
        'userName': _phoneController.text,
        'generatorId': _selectedGeneratorId!,
        'address': _addressController.text,
        'districtName': widget.districtName,
        'province': widget.province,
        'role': 'User',
      };

      final response = await http.post(
        Uri.parse('https://apigenerators.sooqgate.com/api/add_user'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إضافة المستخدم بنجاح'),
          ),
        );
      } else {
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'فشل في إضافة المستخدم: ${response.statusCode} - ${response.body}'),
          ),
        );
      }
    }
  }

  InputDecoration _inputDecoration(String labelText, IconData icon) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
      fillColor: Colors.grey[200],
      prefixIcon: Icon(icon),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 20.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة مستخدم',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _displayNameController,
                  decoration: _inputDecoration('الاسم الكامل', Icons.person),
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
                SizedBox(height: 16), // Add spacing between fields
                TextFormField(
                  controller: _phoneController,
                  decoration: _inputDecoration('رقم الهاتف', Icons.phone),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.almarai(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال رقم الهاتف';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _ampController,
                  decoration: _inputDecoration('الأمبير',
                      Icons.electric_bolt), // Change to an appropriate icon
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.almarai(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال قيمة الأمبير';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: _inputDecoration('العنوان', Icons.location_on),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.almarai(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'يرجى إدخال العنوان';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedGeneratorId,
                  hint: Text(
                    'اختر معرف المولد',
                    style: GoogleFonts.almarai(), // Match the font style
                  ),
                  items: _generators.map((generator) {
                    return DropdownMenuItem<String>(
                      value: generator['electric_generator_id'].toString(),
                      child: Text(
                        'ID: ${generator['electric_generator_id']} - ${generator['full_address']}',
                        style: GoogleFonts.almarai()
                            .copyWith(color: Colors.grey[700]),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGeneratorId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'يرجى اختيار معرف المولد';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'اختر معرف المولد',
                    prefixIcon: Icon(Icons
                        .electrical_services), // Change to an appropriate icon
                    border:
                        OutlineInputBorder(), // Use an outline border similar to TextFormField
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10), // Match padding
                    hintStyle: TextStyle(color: Colors.grey),
                    // Customize hint style
                  ),
                  style: GoogleFonts.almarai(), // Match the font style
                ),

                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addUser,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          'إضافة مستخدم',
                          style: GoogleFonts.cairo(),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchUserPage(
                          token: widget.token,
                          genids: _generatorIds,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'هل لدى المستخدم حساب؟ ابحث عن المستخدم برقم الهاتف',
                    style: GoogleFonts.cairo(
                      color: Colors.teal,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

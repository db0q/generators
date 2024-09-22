import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_data.dart';

class SearchUserPage extends StatefulWidget {
  final String token;
  final genids;
  const SearchUserPage({super.key, required this.token, required this.genids});

  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _userInfo;

  Future<void> _searchUser() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رقم الهاتف')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.get(
      Uri.parse('https://apigenerators.sooqgate.com/api/find/$phone'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    setState(() => _isLoading = false);
    print(response.statusCode);

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      print(userData);
      setState(() {
        _userInfo = userData; // Display user information
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في العثور على المستخدم: ${response.statusCode}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('البحث عن مستخدم'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'أدخل رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _searchUser,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('بحث'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              if (_userInfo != null) ...[
                const SizedBox(height: 20),
                Text(
                  'معلومات المستخدم:',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text('اسم المستخدم: ${_userInfo!['user']['user_name']}'),
                Text('الاسم المعروض: ${_userInfo!['user']["name"]}'),
                Text('الهاتف: ${_userInfo!['user']['phone']}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => UserDataPage(
                          userInfo: _userInfo!,
                          genids: widget.genids,
                          token: widget.token,
                        ),
                      ),
                    );
                  },
                  child: const Text('عرض وتحرير بيانات المستخدم'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserDataPage extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  final String token;
  final Map<String?, dynamic> genids;
  const UserDataPage({
    super.key,
    required this.userInfo,
    required this.token,
    required this.genids,
  });

  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  late List<Map<String, dynamic>> _houses;
  late List<Map<String, dynamic>> _subscriptions;
  List<String> _generatorIds = [];
  String? _selectedGeneratorId;
  bool _isLoading = false;
  final _newHouseController = TextEditingController();
  final _houseIdController = TextEditingController();
  final _ampNoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _houses = List<Map<String, dynamic>>.from(widget.userInfo['houses'] ?? []);
    _subscriptions =
        List<Map<String, dynamic>>.from(widget.userInfo['subscriptions'] ?? []);
    _generatorIds = List<String>.from(widget.genids.keys);
    if (_generatorIds.isNotEmpty) {
      _selectedGeneratorId = _generatorIds[0];
    }
  }

  Future<void> _fetchGenIds() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://localhost:7046/api/gens'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final generators = jsonResponse as List<dynamic>;

        if (generators.isNotEmpty) {
          setState(() {
            _generatorIds = generators
                .map((gen) => gen['electric_generator_id'].toString())
                .toList();
            _selectedGeneratorId =
                _generatorIds.isNotEmpty ? _generatorIds[0] : null;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لا يوجد مولدات متاحة')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في جلب معرفات المولدات')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في جلب معرفات المولدات')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAndAddSubscription() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch generator IDs if not already fetched
    if (_generatorIds.isEmpty) {
      await _fetchGenIds();
    }

    if (_selectedGeneratorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار معرف المولد')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final houseId = _houseIdController.text.trim();
    final ampNo = _ampNoController.text.trim();

    if (houseId.isEmpty || ampNo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال جميع التفاصيل للاشتراك')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Encode data as x-www-form-urlencoded
    final requestBody = {
      'electricGeneratorId': _selectedGeneratorId!,
      'houseId': houseId,
      'ampNo': ampNo,
    };

    // Convert to x-www-form-urlencoded
    final encodedBody = requestBody.entries.map((entry) {
      return '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}';
    }).join('&');

    try {
      final addSubscriptionResponse = await http.post(
        Uri.parse('https://localhost:7046/api/add_subscription'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
        body: encodedBody,
      );

      if (addSubscriptionResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الاشتراك بنجاح')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'فشل في إضافة الاشتراك: ${addSubscriptionResponse.statusCode}\n${addSubscriptionResponse.body}'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في إضافة الاشتراك')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addHouse() {
    final newHouse = _newHouseController.text.trim();
    if (newHouse.isNotEmpty) {
      setState(() {
        _houses.add({'name': newHouse, 'enabled': true});
        _newHouseController.clear();
      });
    }
  }

  void _toggleHouseStatus(int index) {
    setState(() {
      _houses[index]['enabled'] = !_houses[index]['enabled'];
    });
  }

  Future<void> _updateUserData() async {
    if (_selectedGeneratorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد معرف المولد')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final response = await http.put(
      Uri.parse('https://localhost:7046/api/update_user_data'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'houses': jsonEncode(_houses),
        'subscriptions': jsonEncode(_subscriptions),
        'generatorid': _selectedGeneratorId!,
      }.entries.map((entry) {
        return '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}';
      }).join('&'),
    );

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث بيانات المستخدم بنجاح')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'فشل في تحديث بيانات المستخدم: ${response.statusCode}\n${response.body}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل بيانات المستخدم'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'المنازل:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ..._houses.asMap().entries.map((entry) {
              final index = entry.key;
              final house = entry.value;
              return ListTile(
                title: Text(house['name']),
                trailing: Switch(
                  value: house['enabled'],
                  onChanged: (value) => _toggleHouseStatus(index),
                ),
              );
            }).toList(),
            TextField(
              controller: _newHouseController,
              decoration: const InputDecoration(
                labelText: 'أضف منزلًا جديدًا',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: _addHouse,
              child: const Text('إضافة منزل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'الاشتراكات:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            DropdownButtonFormField<String>(
              value: _selectedGeneratorId,
              hint: const Text('اختر معرف المولد'),
              items: _generatorIds.map((id) {
                return DropdownMenuItem<String>(
                  value: id,
                  child: Text('ID: $id'),
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
            ),
            TextField(
              controller: _houseIdController,
              decoration: const InputDecoration(
                labelText: 'رقم المنزل',
                border: OutlineInputBorder(),
              ),
            ),
            TextField(
              controller: _ampNoController,
              decoration: const InputDecoration(
                labelText: 'عدد الأمبيرات',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _fetchAndAddSubscription,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('إضافة اشتراك'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedGeneratorId == null || _isLoading
                  ? null
                  : _updateUserData,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('تحديث بيانات المستخدم'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

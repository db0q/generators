import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'invoices_list.dart';
import 'user_info.dart';
// Add this import for UserInvoicePage

class SubscriptionsAdminPage extends StatefulWidget {
  final String token;
  final String? username;
  final String? displayname;
  final String? phone;
  final String? districtName;
  final String? province;
  final String? role;

  const SubscriptionsAdminPage({
    super.key,
    required this.token,
    required this.username,
    required this.displayname,
    required this.phone,
    required this.districtName,
    required this.province,
    required this.role,
  });

  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsAdminPage> {
  List<dynamic> subscriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    // Example API call to fetch subscriptions
    final response = await http.get(
      Uri.parse('https://localhost:7046/api/subscriptions'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;

      setState(() {
        subscriptions = data; // Store subscriptions
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to fetch subscriptions: ${response.statusCode}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "اشتراكات المنازل",
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 4.0,
      ),
      body: Column(
        children: [
          // User Avatar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfoPage(
                      token: widget.token,
                      displayName: widget.displayname!,
                      username: widget.username!,
                      phone: widget.phone!,
                      districtName: widget.districtName!,
                      province: widget.province!,
                      role: widget.role!,
                    ),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 40,
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildSubscriptionsList(subscriptions),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionsList(List<dynamic> subscriptions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: subscriptions.isEmpty
          ? Center(
              child: Text(
                'لا توجد اشتراكات مسجلة',
                style: GoogleFonts.almarai(
                    fontSize: 18,
                    color: const Color.fromARGB(255, 255, 255, 255)),
              ),
            )
          : ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];
                final code = subscription['code'];
                final startDate = subscription['start_date'];
                final ampNo = subscription['amp_no'];
                final status =
                    subscription['status'] == 0 ? 'غير مفعل' : 'مفعل';

                return Card(
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      'رمز الاشتراك: $code',
                      style: GoogleFonts.almarai(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'التاريخ: $startDate\nالامبير: $ampNo\nالحالة: $status',
                      style: GoogleFonts.almarai(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 97, 97, 97)),
                    ),
                    trailing: const Icon(
                      Icons.electric_bolt,
                      color: Colors.teal,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserInvoicePage(
                            token: widget.token,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

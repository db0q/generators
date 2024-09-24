import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../user_info.dart';
import 'add_user_page.dart';
import 'invoices_list.dart';

class SubscriptionsAdminPage extends StatefulWidget {
  final String token;
  final String username;
  final String displayname;
  final String phone;
  final String districtName;
  final String province;
  final String role;

  const SubscriptionsAdminPage({
    super.key,
    required this.token,
    required this.username,
    required this.displayname,
    required this.phone,
    required this.districtName,
    required this.province,
    required this.role,
    required userId,
  });

  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsAdminPage> {
  List<dynamic> subscriptions = [];
  List<dynamic> filteredSubscriptions = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    setState(() => isLoading = true);

    final response = await http.get(
      Uri.parse('https://apigenerators.sooqgate.com/api/subscriptions'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;
      setState(() {
        subscriptions = data;
        filteredSubscriptions = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Failed to fetch subscriptions: ${response.statusCode}'),
        ),
      );
    }
  }

  void _filterSubscriptions() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        filteredSubscriptions =
            subscriptions; // Show all subscriptions if query is empty
      } else {
        filteredSubscriptions = subscriptions.where((subscription) {
          final houseOwner = (subscription['house_owner'] ?? '').toLowerCase();
          final houseId =
              (subscription['house_id'] ?? '').toString().toLowerCase();
          return houseOwner.contains(query) || houseId.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(255, 255, 255, 255),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.teal.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4.0)
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.person, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserInfoPage(
                              token: widget.token,
                              displayName: widget.displayname,
                              username: widget.username,
                              phone: widget.phone,
                              districtName: widget.districtName,
                              province: widget.province,
                              role: widget.role,
                            ),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            fetchSubscriptions();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 20),
                          ),
                          child: Text(
                            'الصفحة الرئيسية',
                            style: GoogleFonts.cairo(
                              textStyle: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddUserPage(
                              token: widget.token,
                              districtName: widget.districtName,
                              province: widget.province,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'بحث بالمالك أو رقم المنزل',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    ElevatedButton(
                      onPressed: _filterSubscriptions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                      ),
                      child: Text(
                        'بحث',
                        style: GoogleFonts.cairo(
                          textStyle: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildSubscriptionsList(filteredSubscriptions),
              ),
            ],
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
                  color: Colors.black54,
                ),
              ),
            )
          : ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];
                final startDate = subscription['start_date'];
                final ampNo = subscription['amp_no'];
                final house = subscription['house_id'];
                final adress = subscription['address'];
                final houseOwner = subscription['house_owner'] ?? 'غير معروف';
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
                      'رقم المنزل: $house',
                      style: GoogleFonts.almarai(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'المالك: ${houseOwner} \n العنوان:- ${adress}\n التاريخ: $startDate\nالامبير: $ampNo\nالحالة: $status ',
                      style: GoogleFonts.almarai(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
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
                              token: widget.token, houseid: house),
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

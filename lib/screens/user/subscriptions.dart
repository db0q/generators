import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SubscriptionsPage extends StatefulWidget {
  final String token;
  final int houseId;
  const SubscriptionsPage({
    super.key,
    required this.token,
    required this.houseId,
  });

  @override
  _SubscriptionsPageState createState() => _SubscriptionsPageState();
}

class _SubscriptionsPageState extends State<SubscriptionsPage> {
  List<dynamic> unpaidSubscriptions = [];
  List<dynamic> paidSubscriptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubscriptions();
  }

  Future<void> fetchSubscriptions() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://apigenerators.sooqgate.com/api/subscriptions?house_id=${widget.houseId}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;

        setState(() {
          unpaidSubscriptions = data
              .where((subscription) => subscription['status'] == 0)
              .toList();
          paidSubscriptions = data
              .where((subscription) => subscription['status'] == 1)
              .toList();
          isLoading = false; // Hide loading indicator
        });
      } else {
        throw Exception('Failed to load subscriptions');
      }
    } catch (error) {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void _paySubscription(String subscriptionId) async {
    final response = await http.post(
      Uri.parse('https://apigenerators.sooqgate.com/api/pay_subscription'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'subscriptionId': subscriptionId,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم دفع الاشتراك بنجاح!')),
      );
      // Refresh subscriptions after payment
      fetchSubscriptions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في دفع الاشتراك: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "الاشتراكات",
            style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal,
          bottom: PreferredSize(
            preferredSize: const ui.Size.fromHeight(48.0),
            child: Container(
              color: Colors.teal[800],
              child: TabBar(
                tabs: const [
                  Tab(
                    text: 'الاشتراكات غير المدفوعة',
                  ),
                  Tab(
                    text: 'الاشتراكات المدفوعة',
                  ),
                ],
                labelStyle: GoogleFonts.cairo(
                    fontSize: 12, fontWeight: FontWeight.w600),
                labelColor: Colors.white,
                indicatorColor: Colors.orange,
                indicatorWeight: 3.0,
              ),
            ),
          ),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildSubscriptionContainer(
                      unpaidSubscriptions, 'غير مدفوعة'),
                  _buildSubscriptionContainer(paidSubscriptions, 'مدفوعة'),
                ],
              ),
      ),
    );
  }

  Widget _buildSubscriptionContainer(List<dynamic> subscriptions, String type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: subscriptions.isEmpty
          ? Center(child: Text('لا توجد اشتراكات $type'))
          : ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];
                return Card(
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text('اشتراك رقم: ${subscription['id']}',
                            style: GoogleFonts.almarai(
                                fontSize: 18, fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          'المبلغ: ${subscription['amount']} - تاريخ الاشتراك: ${subscription['subscription_date']}',
                          style: GoogleFonts.almarai(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 97, 97, 97)),
                        ),
                        trailing: const Icon(
                          Icons.payment,
                          color: Colors.teal,
                        ),
                        onTap: subscription['status'] == 0
                            ? () => _paySubscription(subscription['house_id'])
                            : null, // Disable tap for paid subscriptions
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

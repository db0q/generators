import 'dart:async';
import 'package:flutter/material.dart';
import 'package:generators/screens/user/subscriptions.dart';
import '../screens/user_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../screens/user/ticket_options_page.dart';

class HomePage extends StatefulWidget {
  final String token;
  final String? username;
  final int userId;
  final String? displayname;
  final String? phone;
  final String? districtName;
  final String? province;
  final String? role;

  const HomePage({
    super.key,
    required this.token,
    required this.userId,
    required this.username,
    required this.displayname,
    required this.phone,
    required this.districtName,
    required this.province,
    required this.role,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> houses = [];
  bool isLoading = true;
  bool _showMessage = false;

  @override
  void initState() {
    super.initState();
    fetchHouses();
    _displayMessage();
  }

  Future<void> fetchHouses() async {
    final response = await http.get(
      Uri.parse('https://apigenerators.sooqgate.com/api/houses'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
      },
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List<dynamic>;

      setState(() {
        houses = data; // Store all houses
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch data: ${response.statusCode}')),
      );
    }
  }

  void _displayMessage() {
    setState(() {
      _showMessage = true;
    });

    // Hide the message after 3 seconds
    Timer(Duration(seconds: 3), () {
      setState(() {
        _showMessage = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            "الصفحة الرئيسية",
            style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.teal,
          elevation: 4.0,
          automaticallyImplyLeading: false),
      body: Stack(
        children: [
          Column(
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
                    : _buildHousesContainer(houses),
              ),
            ],
          ),
          // Message Display
          if (_showMessage)
            Positioned(
              bottom: 30, // Adjust as needed to position the message
              right: 80, // Adjust to position it to the left of the button
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'هل لديك شكوى ؟',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TicketOptionsPage(
                token: widget.token,
                userId: widget.userId, // Pass the token to TicketOptionsPage
              ),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.chat),
      ),
    );
  }

  Widget _buildHousesContainer(List<dynamic> houses) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: houses.isEmpty
          ? Center(
              child: Text(
                'لا توجد بيوت مسجلة',
                style: GoogleFonts.almarai(
                    fontSize: 18, color: const Color.fromARGB(255, 97, 97, 97)),
              ),
            )
          : ListView.builder(
              itemCount: houses.length,
              itemBuilder: (context, index) {
                final house = houses[index];
                final houseid = (house['house_id']);
                return Card(
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      'عنوان: ${house['address']}',
                      style: GoogleFonts.almarai(
                          fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'الحي: ${house['district_council']['name']} - المحافظة: ${house['district_council']['provincial_council']['name']}',
                      style: GoogleFonts.almarai(
                          fontSize: 16,
                          color: const Color.fromARGB(255, 97, 97, 97)),
                    ),
                    trailing: const Icon(
                      Icons.home,
                      color: Colors.teal,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubscriptionsPage(
                            token: widget.token,
                            houseId: houseid,
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

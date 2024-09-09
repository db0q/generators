// import 'dart:ffi';
import 'package:flutter/material.dart';
// import 'package:generators/Widgets/login_page.dart';
import 'package:generators/screens/subscriptions.dart';
import 'package:generators/screens/user_info.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String token;
  final String? username;
  final String? displayname;
  final String? phone;
  final String? districtName;
  final String? province;
  final String? role;
  const HomePage({
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
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> houses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHouses();
  }

  Future<void> fetchHouses() async {
    final response = await http.get(
      Uri.parse('https://localhost:7046/api/houses'),
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
                      username: widget.username!, // Fixed this line
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
                    fontSize: 18,
                    color: const Color.fromARGB(255, 255, 255, 255)),
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

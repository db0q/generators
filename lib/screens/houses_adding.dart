import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HouseFormPage extends StatefulWidget {
  final String token;
  const HouseFormPage({super.key, required this.token});

  @override
  _HouseFormPageState createState() => _HouseFormPageState();
}

class _HouseFormPageState extends State<HouseFormPage> {
  final _formKey = GlobalKey<FormState>();

  // Form field controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _districtCouncilIdController =
      TextEditingController();
  final TextEditingController _districtCouncilNameController =
      TextEditingController();
  final TextEditingController _provincialCouncilNameController =
      TextEditingController();

  bool _isSubmitting = false;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      final response = await http.post(
        Uri.parse('https://localhost:7046/api/add_house'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'address': _addressController.text,
          'district_council_id':
              int.tryParse(_districtCouncilIdController.text),
          'district_council': {
            'district_council_id':
                int.tryParse(_districtCouncilIdController.text),
            'name': _districtCouncilNameController.text,
            'provincial_council_id': 1, // This is static for now
            'provincial_council': {
              'provincial_council_id': 1, // Static value, can be dynamic
              'name': _provincialCouncilNameController.text,
            }
          },
          // Add more fields as needed
        }),
      );

      setState(() {
        _isSubmitting = false;
      });

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('House added successfully!')),
        );
        _formKey.currentState!.reset();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to add house: ${response.statusCode}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New House",
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'House Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the house address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _districtCouncilIdController,
                decoration: InputDecoration(
                  labelText: 'District Council ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the district council ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _districtCouncilNameController,
                decoration: InputDecoration(
                  labelText: 'District Council Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the district council name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _provincialCouncilNameController,
                decoration: InputDecoration(
                  labelText: 'Provincial Council Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the provincial council name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              // Add more fields here as needed
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'Submit',
                        style: GoogleFonts.cairo(fontSize: 18),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

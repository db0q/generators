import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

class TicketChatPage extends StatefulWidget {
  final String token;
  final int userId; // Added userId to the constructor

  TicketChatPage({required this.token, required this.userId});

  @override
  _TicketChatPageState createState() => _TicketChatPageState();
}

class _TicketChatPageState extends State<TicketChatPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitTicket() async {
    final title = _titleController.text;
    final description = _descriptionController.text;

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both title and description')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      HttpClient httpClient = HttpClient();
      HttpClientRequest request = await httpClient.postUrl(
        Uri.parse('https://apigenerators.sooqgate.com/api/ticket/add'),
      );

      request.headers.set('Content-Type', 'application/x-www-form-urlencoded');
      request.headers.set('Accept', 'application/json');
      request.headers
          .set(HttpHeaders.authorizationHeader, 'Bearer ${widget.token}');

      // Create the request body with userId, title, and description as form parameters
      String body =
          'userId=${widget.userId}&title=${Uri.encodeComponent(title)}&description=${Uri.encodeComponent(description)}';
      request.write(body);

      final HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        // Handling the response
        String responseBody = await response.transform(utf8.decoder).join();
        print('Ticket submitted successfully: $responseBody');

        // Clear the form after successful submission
        setState(() {
          _titleController.clear();
          _descriptionController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket submitted successfully')),
        );
      } else {
        print('Failed to submit ticket: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit ticket')),
        );
      }
    } catch (e) {
      print('Error submitting ticket: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting ticket')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket '),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            _isSubmitting
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitTicket,
                    child: Text('Submit Ticket'),
                  ),
          ],
        ),
      ),
    );
  }
}

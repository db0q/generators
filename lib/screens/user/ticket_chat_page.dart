import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

class TicketChatPage extends StatefulWidget {
  final String token;
  final int userId;

  TicketChatPage({required this.token, required this.userId});

  @override
  _TicketChatPageState createState() => _TicketChatPageState();
}

class _TicketChatPageState extends State<TicketChatPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitTicket() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both title and description'),
          backgroundColor: Colors.redAccent,
        ),
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

      String body =
          'userId=${widget.userId}&title=${Uri.encodeComponent(title)}&description=${Uri.encodeComponent(description)}';
      request.write(body);

      final HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        String responseBody = await response.transform(utf8.decoder).join();
        print('تم ارسال الرسالة بنجاح: $responseBody');

        setState(() {
          _titleController.clear();
          _descriptionController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم ارسال الرسالة')),
        );
      } else if (response.statusCode == 400) {
        print('Failed to submit ticket: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاْ تغيير كلمات الرسالة')),
        );
      } else {
        print('فشل ارسال الرسالة: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل ارسال الرسالة')),
        );
      }
    } catch (e) {
      print('Error submitting ticket: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting ticket')),
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
        title: const Text('ارسال'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'انشئ شكوى جديدة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            const SizedBox(height: 20),

            // Title Input
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'العنوان',
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal,
                    ),
                    border: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    hintText: 'ادخل عنوان الشكوى',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description Input
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'الوصف',
                    labelStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.teal,
                    ),
                    border: InputBorder.none,
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                    hintText: 'صف المشكلة او الشكوى',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                  ),
                  maxLines: 5,
                  minLines: 3,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            Center(
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submitTicket,
                      icon: const Icon(Icons.send,
                          size: 24, color: Colors.black87),
                      label: Text('ارسال للدعم',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 221, 221, 221))),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 15,
                        ),
                        backgroundColor: Colors.teal,
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

class ViewTicketsPage extends StatefulWidget {
  final String token;

  ViewTicketsPage({required this.token, required int userId});

  @override
  _ViewTicketsPageState createState() => _ViewTicketsPageState();
}

class _ViewTicketsPageState extends State<ViewTicketsPage> {
  List<dynamic> _tickets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(
        Uri.parse('https://apigenerators.sooqgate.com/api/mytickets'),
      );
      request.headers
          .set(HttpHeaders.authorizationHeader, 'Bearer ${widget.token}');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final decodedData = jsonDecode(responseBody);
        print('Response: $decodedData'); // Log response for debugging

        if (decodedData is List) {
          setState(() {
            _tickets = decodedData;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Invalid response format';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load tickets: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching tickets: $e';
        _isLoading = false;
      });
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return 'مفتوحة';
      case 1:
        return 'جاري المعالجة';
      case 2:
        return 'مغلقة';
      default:
        return 'Unknown Status';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الرسائل السابقة'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _tickets.isEmpty
                  ? Center(child: Text('لا يوجد رسائل'))
                  : ListView.builder(
                      itemCount: _tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = _tickets[index];
                        return ListTile(
                          leading: Icon(Icons.chat_bubble_outline,
                              color: Colors.teal),
                          title: Text('الرسالة #${ticket['ticket_id']}'),
                          subtitle: Text(
                              'الحالة: ${_getStatusText(ticket['stage'])}'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            // Navigate to ticket's chat view when tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TicketChat(
                                  token: widget.token,
                                  ticketId: ticket['ticket_id'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}

class TicketChat extends StatefulWidget {
  final String token;
  final int ticketId;

  TicketChat({required this.token, required this.ticketId});

  @override
  _TicketChatState createState() => _TicketChatState();
}

class _TicketChatState extends State<TicketChat> {
  Map<String, dynamic>? _ticketDetails;
  List<dynamic> _messages = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTicketDetails();
  }

  Future<void> _fetchTicketDetails() async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(
        Uri.parse(
            'https://apigenerators.sooqgate.com/api/tickets/${widget.ticketId}'),
      );
      request.headers
          .set(HttpHeaders.authorizationHeader, 'Bearer ${widget.token}');

      final response = await request.close();
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final data = jsonDecode(responseBody);
        print('Ticket Details Response: $data'); // Log for debugging

        setState(() {
          _ticketDetails = data['ticket'];
          _messages = data['messages'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Failed to load ticket details: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching ticket details: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ticket #${widget.ticketId}'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Subject: ${_ticketDetails!['subject']}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return ListTile(
                            title: Text(message['content']),
                            subtitle: Text('From: ${message['sender']}'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}

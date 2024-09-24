import 'package:flutter/material.dart';
import 'package:generators/screens/user/ticket_chat_page.dart';
import 'package:generators/screens/user/view_tickets_page.dart';

class TicketOptionsPage extends StatelessWidget {
  final String token; // Pass the token to this page
  final int userId; // Pass the user ID to this page

  TicketOptionsPage({required this.token, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support Tickets'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Navigate to view all tickets
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewTicketsPage(token: token, userId: userId),
                  ),
                );
              },
              child: Text('View All Tickets'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
            SizedBox(height: 20), // Add spacing between the buttons
            ElevatedButton(
              onPressed: () {
                // Navigate to the chat page to send a new ticket
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TicketChatPage(token: token, userId: userId),
                  ),
                );
              },
              child: Text('Send New Ticket'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

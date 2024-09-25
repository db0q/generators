import 'package:flutter/material.dart';
import 'package:generators/screens/user/ticket_chat_page.dart';
import 'package:generators/screens/user/view_tickets_page.dart';

class TicketOptionsPage extends StatelessWidget {
  final String token; // Token for API authentication
  final int userId; // User ID for user-specific data

  const TicketOptionsPage({
    Key? key,
    required this.token,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Tickets'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTicketOptionCard(
                context,
                label: 'View All Tickets',
                icon: Icons.view_list_rounded,
                gradientColors: [Colors.teal, Colors.teal.shade700],
                onPressed: () => _navigateToViewTicketsPage(context),
              ),
              const SizedBox(height: 20),
              _buildTicketOptionCard(
                context,
                label: 'Send New Ticket',
                icon: Icons.chat_rounded,
                gradientColors: [Colors.orange, Colors.orange.shade700],
                onPressed: () => _navigateToTicketChatPage(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable method to build professional-looking buttons using a gradient and icon
  Widget _buildTicketOptionCard(BuildContext context,
      {required String label,
      required IconData icon,
      required List<Color> gradientColors,
      required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigate to the ViewTicketsPage
  void _navigateToViewTicketsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewTicketsPage(
          token: token,
          userId: userId,
        ),
      ),
    );
  }

  // Navigate to the TicketChatPage for sending a new ticket
  void _navigateToTicketChatPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TicketChatPage(
          token: token,
          userId: userId,
        ),
      ),
    );
  }
}

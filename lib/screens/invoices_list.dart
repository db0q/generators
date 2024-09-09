import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserInvoicePage extends StatefulWidget {
  final String token; // Add this line to accept the token

  UserInvoicePage({required this.token}); // Update constructor to accept token

  @override
  _UserInvoicePageState createState() => _UserInvoicePageState();
}

class _UserInvoicePageState extends State<UserInvoicePage> {
  List<dynamic> invoices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInvoices();
  }

  Future<void> fetchInvoices() async {
    try {
      final response = await http.get(
        Uri.parse('https://localhost:7046/api/getlistinvoices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${widget.token}', // Use the passed token
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          invoices = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load invoices');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching invoices: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "الفواتير",
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 4.0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildInvoiceList(invoices),
    );
  }

  Widget _buildInvoiceList(List<dynamic> invoices) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: invoices.isEmpty
          ? Center(
              child: Text(
                'لا توجد فواتير',
                style: GoogleFonts.almarai(
                  fontSize: 18,
                  color: const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            )
          : ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                final invoiceId = invoice['invoice_id'];
                final dueYear = invoice['due_year'];
                final dueMonth = invoice['due_month'];
                final dueAmount = invoice['due_amount'];
                final issuingDate = DateTime.parse(invoice['issuing_date']);
                final ampNo = invoice['amp_no'];
                final isPaid = invoice['is_paid'] ? 'مدفوع' : 'غير مدفوع';

                return Card(
                  elevation: 6.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(
                      'فاتورة رقم: $invoiceId',
                      style: GoogleFonts.almarai(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'تاريخ الاستحقاق: $dueYear/$dueMonth\n'
                      'المبلغ المستحق: $dueAmount IQD\n'
                      'تاريخ الإصدار: ${issuingDate.toLocal()}\n'
                      'عدد الامبيرات: $ampNo\n'
                      'الحالة: $isPaid',
                      style: GoogleFonts.almarai(
                        fontSize: 16,
                        color: const Color.fromARGB(255, 97, 97, 97),
                      ),
                    ),
                    trailing: Icon(
                      isPaid == 'مدفوع' ? Icons.check_circle : Icons.warning,
                      color: isPaid == 'مدفوع' ? Colors.green : Colors.red,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

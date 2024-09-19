import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  String? _message;

  void _sendOtp() async {
    final phone = _phoneController.text;

    if (phone.isEmpty) {
      setState(() {
        _message = 'يرجى إدخال رقم الهاتف الخاص بك.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    // Simulate sending OTP
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _otpSent = true;
      _message = 'تم إرسال رمز التحقق إلى رقم الهاتف الخاص بك.';
    });

    // Here you would typically call an API to send the OTP
    // final response = await http.post(
    //   Uri.parse('https://yourapi.com/send-otp'),
    //   body: json.encode({'phone': phone}),
    //   headers: {'Content-Type': 'application/json'},
    // );
  }

  void _verifyOtp() async {
    final otp = _otpController.text;

    if (otp.isEmpty) {
      setState(() {
        _message = 'يرجى إدخال رمز التحقق.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    // Simulate OTP verification
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _message =
          'تم التحقق من رمز التحقق بنجاح. يمكنك الآن إعادة تعيين كلمة المرور.';
    });

    // Here you would typically call an API to verify the OTP
    // final response = await http.post(
    //   Uri.parse('https://yourapi.com/verify-otp'),
    //   body: json.encode({'otp': otp}),
    //   headers: {'Content-Type': 'application/json'},
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إعادة تعيين كلمة المرور',
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 4.0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _otpSent
                  ? 'أدخل رمز التحقق المرسل إلى رقم الهاتف الخاص بك.'
                  : 'أدخل رقم الهاتف الخاص بك لتلقي رمز التحقق.',
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            if (!_otpSent) ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              SizedBox(height: 20),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _sendOtp,
                  child: Text('إرسال رمز التحقق'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
            ] else ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'رمز التحقق',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 20),
              if (_isLoading)
                Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _verifyOtp,
                  child: Text('التحقق من رمز التحقق'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    textStyle: TextStyle(fontSize: 16),
                  ),
                ),
            ],
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        _message!.startsWith('إذا') ? Colors.green : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

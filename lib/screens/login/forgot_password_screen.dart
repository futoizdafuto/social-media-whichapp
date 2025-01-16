import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socially_app_flutter_ui/screens/login/login_screen.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/login/verify_otp_forgot_password_screen.dart';
import 'package:socially_app_flutter_ui/screens/register/widgets/register_widget.dart';
import 'package:socially_app_flutter_ui/services/ForgotPasswordServices.dart';
import 'package:socially_app_flutter_ui/services/VerifyOTPMailServices.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;



Future<void> handleVerifyEmail() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String email = _emailController.text;

    // Gọi Verifyotpmailservices
    final verifyEmailService = Forgotpasswordservices();
  String? emailUser = await verifyEmailService.getEmail();
    final response = await verifyEmailService.sendForgotPasswordRequest(email);

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 'success') {
      // OTP thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
           builder: (context) => VerifyOtpForgotPasswordScreen(email: emailUser ?? ''),
        ),
      );
    } else {
      // OTP thất bại
      setState(() {
        _errorMessage = response['message'];
      });
    }
  }
}


   @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return RegisterBackground(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quên mật khẩu'),
          backgroundColor: k2MainThemeColor,
        ),
        backgroundColor: Colors.transparent, // Đặt nền trong suốt
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nhập email hoặc username',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 1, 16, 43),
                          ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Để lấy lại mật khẩu, vui lòng nhập email hoặc username:',
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                
                    const SizedBox(height: 20.0),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Email hoặc username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Không được để trống';
                              } 
                              return null;
                            },
                          ),
                        ),
                     
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: _isLoading ? null : () => handleVerifyEmail(),
                      child: Container(
                        width: size.width * 0.75,
                        height: 55.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _isLoading
                              ? Colors.grey
                              : const Color.fromARGB(255, 0, 0, 0),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Xác thực Email',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall!
                                        .copyWith(
                                          color: const Color.fromARGB(
                                              255, 255, 255, 255),
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(width: 16.0),
                                  SvgPicture.asset(
                                    'assets/icons/arrow_forward.svg',
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                  ),
                                ],
                              ),
                      ),
                    ),
                
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
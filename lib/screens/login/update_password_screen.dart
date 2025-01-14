import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socially_app_flutter_ui/screens/login/login_screen.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/login/verify_otp_forgot_password_screen.dart';
import 'package:socially_app_flutter_ui/screens/register/widgets/register_widget.dart';
import 'package:socially_app_flutter_ui/services/ForgotPasswordServices.dart';
import 'package:socially_app_flutter_ui/services/VerifyOTPMailServices.dart';

class UpdatePasswordScreen extends StatefulWidget {
 const UpdatePasswordScreen({Key? key}) : super(key: key);

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isObscure = true;


Future<void> handleVerifyEmail() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String password = _passwordController.text; // Lấy mã OTP từ TextFormField

    // Gọi Verifyotpmailservices
    final verifyEmailService = Forgotpasswordservices();
    final response = await verifyEmailService.updatePassword(password);

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
           builder: (context) => LoginScreen(),
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
          title: const Text('Lấy lại mật khẩu'),
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
                      'Nhập mật khẩu mới của bạn',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 1, 16, 43),
                          ),
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
                            controller: _passwordController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure;
                            });
                          },
                        ),
                      ),
                            validator: (value) {
                               if (value == null || value.isEmpty) {
                          return 'Mật khẩu không được để trống';
                        } else if (value.length < 6) {
                          return 'Mật khẩu phải có ít nhất 6 ký tự';
                        } else if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
                          return 'Mật khẩu phải có ít nhất 1 chữ số';
                        } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
                          return 'Mật khẩu phải có ít nhất 1 ký tự viết hoa';
                        }
                        return null;
                            },
                          ),
                        ),
                     
                      ],
                    ),
                    const SizedBox(height: 10.0),
                        // Trường nhập lại mật khẩu
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        labelText: 'Nhập lại mật khẩu',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isObscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure = !_isObscure; // Toggle password visibility
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Mật khẩu không khớp';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),


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
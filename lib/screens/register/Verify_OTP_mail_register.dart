import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socially_app_flutter_ui/screens/login/login_screen.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/register/widgets/register_widget.dart';
import 'package:socially_app_flutter_ui/services/VerifyOTPMailServices.dart';

class VerifyOtpMailRegister extends StatefulWidget {
  final String email;

  const VerifyOtpMailRegister({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<VerifyOtpMailRegister> createState() => _VerifyOtpMailRegisterState();
}

class _VerifyOtpMailRegisterState extends State<VerifyOtpMailRegister> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  int _secondsRemaining = 120; // 2 phút
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

Future<void> handleVerifyOtp() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String otp = _otpController.text; // Lấy mã OTP từ TextFormField

    // Gọi Verifyotpmailservices
    final verifyService = Verifyotpmailservices();
    final response = await verifyService.verifyOtp(otp);

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
          builder: (context) => const LoginScreen(),
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
          title: const Text('Xác thực Email'),
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
                      'Nhập mã OTP',
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 1, 16, 43),
                          ),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      'Đã gửi mã xác thực đến email:',
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      widget.email,
                      style: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
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
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Mã OTP',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Không được để trống';
                              } else if (value.length != 6) {
                                return 'Phải có 6 chữ số';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        SizedBox(
                          width: 80,
                          child: Text(
                            _secondsRemaining > 0
                                ? '$_secondsRemaining giây'
                                : 'Hết giờ!',
                            style: TextStyle(
                              color: _secondsRemaining > 0
                                  ? Colors.black
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: _isLoading ? null : () => handleVerifyOtp(),
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
                    const SizedBox(height: 10.0),
                    if (_secondsRemaining == 0)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _secondsRemaining = 120;
                            _startCountdown();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã gửi lại mã OTP!'),
                            ),
                          );
                        },
                        child: const Text(
                          'Gửi lại mã OTP',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
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
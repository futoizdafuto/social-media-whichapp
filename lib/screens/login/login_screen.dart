import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';

import '../../config/colors.dart';
import 'package:socially_app_flutter_ui/screens/nav/nav.dart';
import 'widgets/login_widget.dart';
import 'package:socially_app_flutter_ui/screens/register/RegisterScreen.dart';
import 'package:socially_app_flutter_ui/services/LoginServices.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isObscure = true; // hiển thị mật khẩu
  final LoginService _loginService = LoginService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _errorMessage; 
 @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  // Tự động đăng nhập khi có token cũ
  void _autoLogin() async {
    final oldToken = await _loginService.getToken();
    print('Token cũ khi khởi động: $oldToken'); // In token ra để kiểm tra

    if (oldToken != null) {
      final result = await _loginService.reLogin(oldToken);
      print('Kết quả reLogin: $result'); // Để kiểm tra response từ reLogin

      if (result['status'] == 'success') {
        print('Re-login thành công với token mới: ${result['newToken']}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Nav()), // Điều hướng tới màn hình chính
        );
      } else {
        print('Re-login thất bại: ${result['message']}');
      }
    }
  }

void _handleGoogleLogin() async {
  final result = await _loginService.loginWithGoogle();

  if (result['status'] == 'success') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Nav()),
    );
  } else {
    setState(() {
      _errorMessage = result['message'];
    });
  }
}

    void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final username = _emailController.text;
      final password = _passwordController.text;

      final result = await _loginService.login(username, password);
      if (result['status'] == 'success') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Nav()),
        );
      } else {
        // Update the error message based on login result
        setState(() {
          _errorMessage = result['message'];
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return LoginBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                    // Tiêu đề đăng nhập
                    Text(
                      'Đăng nhập',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontSize: 42.0, // Kích thước chữ lớn hơn
                            color: const Color.fromARGB(255, 1, 16, 43),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5, // Khoảng cách giữa các chữ cái
                          ),
                    ),
                                     const SizedBox(height: 20.0),
   // Display error message below the username field
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 20.0),

                    // Trường nhập email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email hoặc username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập email hoặc username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),

                    // Trường nhập mật khẩu
                    TextFormField(
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
                            _isObscure
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscure =
                                  !_isObscure; // Toggle password visibility
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập mật khẩu';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 40.0),

                    // Nút đăng nhập
                    GestureDetector(
                       onTap: _handleLogin,
             
                      child: Container(
                        width: size.width * 0.75,
                        height: 55.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: k2MainThemeColor,
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Đăng nhập',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 16.0),
                            SvgPicture.asset(
                              'assets/icons/arrow_forward.svg',
                              color: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Nút đăng nhập bằng Google
                    GestureDetector(
                     onTap: _handleGoogleLogin,
                      child: Container(
                        width: size.width * 0.75,
                        height: 55.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white, // Nền trắng cho nút Google
                          borderRadius: BorderRadius.circular(30.0),
                          border:
                              Border.all(color: Colors.grey), // Viền xám nhẹ
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/google_logo.svg.svg', // Đảm bảo có biểu tượng Google trong thư mục assets
                              height: 24.0, // Kích thước biểu tượng
                            ),
                            const SizedBox(width: 16.0),
                            Text(
                              'Đăng nhập bằng Google',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                    color: Colors.black,
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    // Dòng hỏi chưa có tài khoản
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Chưa có tài khoản?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Registerscreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Đăng ký',
                            style: TextStyle(
                              color: Colors.blue, // Màu của chữ Đăng ký
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
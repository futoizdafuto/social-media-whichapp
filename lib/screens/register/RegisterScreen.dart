import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socially_app_flutter_ui/services/RegisterService.dart';

import '../../config/colors.dart';
import 'package:socially_app_flutter_ui/screens/nav/nav.dart';
import 'widgets/register_widget.dart';
import 'package:socially_app_flutter_ui/screens/login/login_screen.dart';

class Registerscreen extends StatefulWidget {
  const Registerscreen({Key? key}) : super(key: key);

  @override
  State<Registerscreen> createState() => _RegisterscreenState();
}

class _RegisterscreenState extends State<Registerscreen> {
  final _formKey = GlobalKey<FormState>(); // Key for the form

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController(); // Name controller
  bool _isObscure = true;
  String? _errorMessage; // Để hiển thị thông báo lỗi
 // Hàm xử lý đăng ký
  Future<void> handleRegister() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String password = _passwordController.text;
      String email = _emailController.text;
      String name = _nameController.text;

      final registerService = RegisterService();
      final response = await registerService.register(username, password, email, name);

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công!')),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
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
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey, // Attach the form key
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tiêu đề đăng ký
                    Text(
                      'Đăng Ký',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontSize: 42.0, // Kích thước chữ lớn hơn
                            color: const Color.fromARGB(255, 1, 16, 43),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5, // Khoảng cách giữa các chữ cái
                          ),
                    ),
                    const SizedBox(height: 10.0),

                    // Hiển thị thông báo lỗi nếu có
                    if (_errorMessage != null) ...[
                
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 10.0),
                    
// Trường nhập username
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username không được để trống';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),

                    // Trường nhập email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email không được để trống';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Email không hợp lệ';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10.0),
// Trường nhập tên
                    TextFormField(
                      controller: _nameController, // Use the name controller
                      decoration: InputDecoration(
                        labelText: 'Tên',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tên không được để trống';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 10.0),

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

                    // Nút đăng ký và xử lý lỗi
                    GestureDetector(
                      onTap: () => handleRegister(),
                      child: Container(
                        width: size.width * 0.75,
                        height: 55.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Đăng ký',
                              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                    color: const Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 16.0),
                            SvgPicture.asset(
                              'assets/icons/arrow_forward.svg',
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 5.0),

                    // Dòng hỏi đã có tài khoản chưa
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Đã có tài khoản?"),
                        TextButton(
                          onPressed: () {
                            // Điều hướng đến trang đăng nhập
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Đăng nhập',
                            style: TextStyle(
                              color: Colors.blue, // Màu của chữ Đăng nhập
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

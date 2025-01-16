import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socially_app_flutter_ui/screens/home/AdminPanelScreen.dart';
import 'package:socially_app_flutter_ui/screens/login/forgot_password_screen.dart';
import 'package:socially_app_flutter_ui/screens/register/InformationScreen.dart';
import 'package:socially_app_flutter_ui/screens/register/Verify_OTP_mail_register.dart';
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
    final name = await _loginService.getNameUser();
    if (oldToken != null) {
      final result = await _loginService.reLogin(oldToken);
      print('Kết quả reLogin: $result'); // Để kiểm tra response từ reLogin
          print('Ten cua user: $name');
      if (result['status'] == 'success') {
        print('Re-login thành công với token mới: ${result['newToken']}');
     if (result['role'] == 1) {
        // Nếu role là 1, chuyển đến AdminPanelScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPanelScreen()),
        );
      } else {
        // Nếu role là 2, chuyển đến Nav
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Nav()),
        );
      }
        // );
      } else {
        print('Re-login thất bại: ${result['message']}');
      }
    }
  }

void _handleGoogleLogin() async {
  try {
    final result = await _loginService.loginWithGoogle();
       final name = await _loginService.getNameUser();
    if (result['status'] == 'success') {
          print('Ten cua user: $name');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Nav()),
      );
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Lỗi đăng nhập Google';
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Lỗi kết nối khi đăng nhập Google: $e';
    });
  }
}

  void _handleLogin() async {
  if (_formKey.currentState!.validate()) {
    final username = _emailController.text;
    final password = _passwordController.text;

    final result = await _loginService.login(username, password);
    if (result['status'] == 'success') {
      int role = result['role'];
      // Lấy giá trị gender, birthday và avatarUrl từ storage
      String? gender = await _storage.read(key: 'gender');
      String? birthday = await _storage.read(key: 'birthday');
      String? avatarUrl = await _storage.read(key: 'avatarUrl');
     // Kiểm tra và in ra kết quả
  print("Gender: ${gender ?? 'Không có dữ liệu'}");
  print('Birthday: ${birthday ?? 'Không có dữ liệu'}');
  print('AvatarUrl: ${avatarUrl ?? 'Không có dữ liệu'}');
      if (role == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPanelScreen()),
        );
      } else {
        // Kiểm tra nếu một trong các giá trị này là null hoặc rỗng
      if (gender == null || gender.isEmpty || birthday == null || birthday.isEmpty || avatarUrl == null || avatarUrl.isEmpty) {
        // Nếu bất kỳ giá trị nào là null hoặc rỗng, chuyển đến trang GenderSelectionScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GenderSelectionScreen()),
        );
      } else {
        // Nếu tất cả các giá trị đều có, chuyển đến trang Nav
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Nav()),
        );
      }
      }
    } else {
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

    // Dòng hỏi chưa có tài khoản
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Quên mật khẩu?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Lấy lại mật khẩu',
                            style: TextStyle(
                              color: Colors.blue, // Màu của chữ Đăng ký
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),




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


     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Test?"),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>  GenderSelectionScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Lấy lại mật khẩu',
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
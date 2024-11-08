import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;
import 'package:socially_app_flutter_ui/screens/login/login_screen.dart';
import 'package:socially_app_flutter_ui/services/LoginServices.dart';
class SettingProfileScreen extends StatefulWidget {
  const SettingProfileScreen({Key? key}) : super(key: key);

  @override
  State<SettingProfileScreen> createState() => _SettingProfileScreenState();
}

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  String _selectedTab = 'photos';
  final LoginService _loginService = LoginService();
  


  _changeTab(String tab) {
    setState(() => _selectedTab = tab);
  }

  @override
  Widget build(BuildContext context) {
   return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.5, // Half the screen
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Text(
                      'Tùy chọn',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            fontSize: 22.0, // Kích thước chữ lớn hơn
                            color: const Color.fromARGB(255, 1, 16, 43),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5, // Khoảng cách giữa các chữ cái
                          ),
                    ),
          const SizedBox(height: 16.0),
          ListTile(
            leading: Icon(Icons.edit),
            title: const Text('Chỉnh sửa thông tin'),
            onTap: () {
              Navigator.pop(context); // Close the modal
              print('Chỉnh sửa thông tin');
              // Handle edit profile action
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: const Text('Cài đặt tài khoản'),
            onTap: () {
              Navigator.pop(context); // Close the modal
              print('Cài đặt tài khoản');
              // Handle account settings action
            },
          ),
         ListTile(
  leading: Icon(Icons.logout),
  title: const Text('Đăng xuất'),
  onTap: () async {
    Navigator.pop(context); // Đóng modal trước khi thực hiện logout

    // Gọi API logout
    final response = await _loginService.logout();

    if (response['status'] == 'success') {
      // Xóa token và userId đã lưu, điều hướng đến màn hình đăng nhập
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      // Thông báo lỗi nếu logout thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  },
),

        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;
import 'package:socially_app_flutter_ui/screens/login/login_screen.dart';
class SettingProfileScreen extends StatefulWidget {
  const SettingProfileScreen({Key? key}) : super(key: key);

  @override
  State<SettingProfileScreen> createState() => _SettingProfileScreenState();
}

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  String _selectedTab = 'photos';

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
            onTap: () {
              Navigator.pop(context); // Close the modal
              // Navigate to LoginScreen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}


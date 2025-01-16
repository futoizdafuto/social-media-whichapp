import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:math' as math;
import 'package:socially_app_flutter_ui/screens/login/login_screen.dart';
import 'package:socially_app_flutter_ui/services/LoginServices.dart';
import 'package:socially_app_flutter_ui/screens/profile/block_list_screen.dart';
import 'package:socially_app_flutter_ui/services/BlockServices.dart';
import 'package:socially_app_flutter_ui/services/FollowServices.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingProfileScreen extends StatefulWidget {
  const SettingProfileScreen({Key? key}) : super(key: key);

  @override
  State<SettingProfileScreen> createState() => _SettingProfileScreenState();

}

class _SettingProfileScreenState extends State<SettingProfileScreen> {
  String _selectedTab = 'photos';

  final LoginService _loginService = LoginService();
  final BlockService _blockService = BlockService();
  final FollowService _followService = FollowService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();



  // Method to change tab if needed
  _changeTab(String tab) {
      setState(() => _selectedTab = tab);

  }
  Future<void> _handlePrivacyTap() async {
    final realUserName = await _storage.read(key: 'realuserName');
    if (realUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to get real username")));
      return;
    }

    // Lấy trạng thái quyền riêng tư hiện tại của người dùng
    final response = await _followService.getUserStatus(realUserName);

    if (response['status'] == 'success') {
      bool isPrivate = response['private'];

      // Hiển thị hộp thoại phù hợp với trạng thái quyền riêng tư hiện tại
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(isPrivate ? "Chế độ riêng tư" : "Chế độ công khai"),
            content: Text(isPrivate
                ? "Tài khoản của bạn đang ở chế độ riêng tư. Bạn có muốn chuyển về chế độ công khai không?"
                : "Tài khoản của bạn đang ở chế độ công khai. Bạn có muốn chuyển về chế độ riêng tư không?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng hộp thoại nếu người dùng không đồng ý
                },
                child: Text("Hủy"),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Đóng hộp thoại sau khi người dùng xác nhận

                  // Thực hiện thay đổi trạng thái quyền riêng tư
                  Map<String, dynamic> updateResponse;

                  if (isPrivate) {
                    // Nếu trạng thái hiện tại là private, chuyển sang công khai
                    updateResponse = await _followService.updatePublic(realUserName);
                  } else {
                    // Nếu trạng thái hiện tại là public, chuyển sang riêng tư
                    updateResponse = await _followService.updatePrivate(realUserName);
                  }

                  if (updateResponse['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(updateResponse['message'])),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(updateResponse['message'])),
                    );
                  }
                },
                child: Text(isPrivate ? "Chuyển sang công khai" : "Chuyển sang riêng tư"),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Lỗi khi lấy trạng thái")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.5,
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
              fontSize: 22.0,
              color: const Color.fromARGB(255, 1, 16, 43),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16.0),
    
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Quyền riêng tư'),
            onTap: _handlePrivacyTap, // Gọi phương thức khi tap vào quyền riêng tư
          ),
          // ListTile(
          //   leading: const Icon(Icons.settings),
          //   title: const Text('Cài đặt tài khoản'),
          //   onTap: () {
          //     Navigator.pop(context);
          //     print('Cài đặt tài khoản');
          //   },
          // ),
          
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Danh sách chặn'),
            onTap: _navigateToBlockedList,
          ),
          ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () async{
                Navigator.pop(context);

                // Call the logout API
                final response = await _loginService.logout();

                if (response['status'] == 'success') {
                  // Clear user data and navigate to login screen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (Route<dynamic> route) => false,
                  );
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'])),
                  );
                }
              }
          ),
        ],
      ),

    );
  }

  // Method to handle logout functionality


  // Method to handle blocked users list navigation
  Future<void> _navigateToBlockedList() async {
    // Close the modal before navigating
    Navigator.pop(context);

    // Call the BlockService API to get blocked users
    final response = await _blockService.getBlock();

    if (response['status'] == 'success') {
      // Navigate to the blocked users screen and pass the blocked users list
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlockedListScreen(
            blockedUsers: List<String>.from(response['blocked_users']),
            onUpdateBlockedUsers: (updatedList) {
              // Optionally handle the updated list here if needed
              setState(() {
                // Update your blocked list if necessary
              });
            },
          ),
        ),
      );
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }


}

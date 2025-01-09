import 'package:flutter/material.dart';
import 'package:socially_app_flutter_ui/screens/login/login_screen.dart';
import 'package:socially_app_flutter_ui/screens/profile/block_list_screen.dart';
import 'package:socially_app_flutter_ui/services/BlockServices.dart';
import 'package:socially_app_flutter_ui/services/LoginServices.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../profilefollow_screen.dart';

class SettingUserProfileScreen extends StatefulWidget {
  final String username; // The username received from ProfileScreen

  const SettingUserProfileScreen({
    Key? key,
    required this.username, // Pass the username here
  }) : super(key: key);

  @override
  State<SettingUserProfileScreen> createState() => _SettingUserProfileScreenState();
}

class _SettingUserProfileScreenState extends State<SettingUserProfileScreen> {
  final LoginService _loginService = LoginService();
  final BlockService _blockService = BlockService();
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Instance for secure storage

  String? _realUsername;
  bool _isUserBlocked = false;

  // Method to get the real username from storage
  Future<void> _getRealUsername() async {
    _realUsername = await _storage.read(key: 'realuserName');

    if (_realUsername == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể lấy tên người dùng.')),
      );
      return;
    }
    // Once real username is fetched, check if the user is blocked
    await _checkIfUserIsBlocked();
  }

  // Method to check if the username passed is in the blocked list
  Future<void> _checkIfUserIsBlocked() async {
    final response = await _blockService.getBlock();

    if (response['status'] == 'success') {
      List<String> blockedUsers = List<String>.from(response['blocked_users']);
      setState(() {
        // Check if the passed username is in the blocked list
        _isUserBlocked = blockedUsers.contains(widget.username);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }

  // Method to handle logout functionality
  Future<void> _handleLogout() async {
    Navigator.pop(context);

    final response = await _loginService.logout();

    if (response['status'] == 'success') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }

  // Method to handle blocked users list navigation
  Future<void> _navigateToBlockedList() async {
    Navigator.pop(context);

    final response = await _blockService.getBlock();

    if (response['status'] == 'success') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlockedListScreen(
            blockedUsers: List<String>.from(response['blocked_users']),
            onUpdateBlockedUsers: (updatedList) {
              setState(() {
                // Update your blocked list if necessary
              });
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }

  // Method to show confirmation dialog for blocking or unblocking
  Future<void> _showConfirmationDialog(String action) async {
    String message = action == 'block'
        ? 'Bạn có muốn chặn người dùng này không?'
        : 'Bạn có muốn bỏ chặn người dùng này không?';

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(action == 'block' ? 'Chặn người dùng' : 'Bỏ chặn người dùng'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Cancel
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Confirm
              },
              child: Text('Đồng ý'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (action == 'block') {
        await _handleBlockUser();
      } else {
        await _handleUnblockUser();
      }
    }
  }

  // Method to block user
  Future<void> _handleBlockUser() async {
    if (_realUsername == null) return;

    final response = await _blockService.blockUser( widget.username);

    if (response['status'] == 'success') {
      setState(() {
        _isUserBlocked = true; // Mark as blocked
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User blocked successfully')),
      );

      // Reload ProfileFollowScreen after blocking
      _reloadProfileScreen();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }

  // Method to unblock user
  Future<void> _handleUnblockUser() async {
    if (_realUsername == null) return;

    final response = await _blockService.unblockUser( widget.username);

    if (response['status'] == 'success') {
      setState(() {
        _isUserBlocked = false; // Mark as unblocked
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User unblocked successfully')),
      );

      // Reload ProfileFollowScreen after unblocking
      _reloadProfileScreen();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );
    }
  }

  // Reload ProfileFollowScreen after blocking/unblocking
  void _reloadProfileScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileFollowScreen(username: widget.username, followingList: [], followedList: [],), // Replace with the ProfileFollowScreen
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getRealUsername(); // Get the real username when the screen loads
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
              leading: const Icon(Icons.edit),
              title: const Text('Đăng xuất'),
              onTap: _handleLogout,
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Danh sách chặn'),
              onTap: _navigateToBlockedList,
            ),
            // Display Block/Unblock option based on whether the current username is in the blocked list
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: Text(
                _isUserBlocked ? 'Bỏ chặn người dùng' : 'Chặn người dùng',
              ),
              onTap: () {
                _showConfirmationDialog(
                    _isUserBlocked ? 'unblock' : 'block');
              },
            ),
          ],
        ),
      ),
    );
  }
}

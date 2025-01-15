// Import necessary packages
import 'package:flutter/material.dart';
import 'package:socially_app_flutter_ui/screens/login/login_screen.dart';
import 'package:socially_app_flutter_ui/services/LoginServices.dart';

class AdminPanelScreen extends StatefulWidget {
  @override
  _AdminPanelScreenState createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  int _currentIndex = 0;
 final LoginService _loginService = LoginService();
  final List<Widget> _tabs = [
    UserManagementPage(),
    PostManagementPage(),
  ];

 Future<void> _logout() async {
    // Hiển thị dialog xác nhận
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận"),
        content: Text("Bạn có chắc chắn muốn đăng xuất không?"),
        actions: [
          TextButton(
            child: Text("Hủy"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text("Đồng ý"),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Gọi API đăng xuất
      final response = await _loginService.logout();

      if (response['status'] == 'success') {
        // Xóa dữ liệu người dùng và chuyển về trang LoginScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Color(0xFFE1F6F4),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Color(0xFF00BFA5),
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFFE1F6F4),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Users",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: "Posts",
          ),
        ],
      ),
    );
  }
}



class UserManagementPage extends StatefulWidget {
  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  final LoginService _loginService = LoginService();
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await _loginService.getAllUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải danh sách người dùng: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFE1F6F4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quản lý người dùng",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00BFA5),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00BFA5),
                      ),
                    )
                  : _users.isEmpty
                      ? Center(child: Text("Không có người dùng nào."))
                      : ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return UserCard(
                              index: index,
                              userName: user['name'],
                              email: user['email'],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class PostManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFE1F6F4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Post Management",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF00BFA5)),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return PostCard(index: index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final int index;
  final String userName;
  final String email;

  UserCard({
    required this.index,
    required this.userName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFF00BFA5),
          child: Text(
            userName[0].toUpperCase(),
            style: TextStyle(color: Colors.white),
          ),
        ),
        title: Text(userName),
        subtitle: Text(email),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(value: "edit", child: Text("Edit")),
            PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
          onSelected: (value) {
            if (value == "edit") {
              // Handle edit user logic
            } else if (value == "delete") {
              // Handle delete user logic
            }
          },
        ),
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final int index;

  PostCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          Icons.post_add,
          color: Color(0xFF00BFA5),
        ),
        title: Text("Post ${index + 1}"),
        subtitle: Text("This is a sample post content ${index + 1}"),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(value: "edit", child: Text("Edit")),
            PopupMenuItem(value: "delete", child: Text("Delete")),
          ],
          onSelected: (value) {
            if (value == "edit") {
              // Handle edit post logic
            } else if (value == "delete") {
              // Handle delete post logic
            }
          },
        ),
      ),
    );
  }
}

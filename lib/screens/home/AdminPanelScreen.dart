// Import necessary packages
import 'package:flutter/material.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/login/login_screen.dart';
import 'package:socially_app_flutter_ui/services/LoginServices.dart';
import 'package:socially_app_flutter_ui/data/repository/post_repository.dart';
import 'package:socially_app_flutter_ui/data/models/post/post.dart';

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

class PostManagementPage extends StatefulWidget {
  @override
  _PostManagementPageState createState() => _PostManagementPageState();
}

class _PostManagementPageState extends State<PostManagementPage> {
  late Future<List<Post>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = PostRepository().fetchPost(); // Lấy danh sách bài đăng khi màn hình được hiển thị
  }

  void _deletePost(int postId) async {
    await PostRepository().deletePost(postId); // Gọi phương thức xóa bài đăng từ repository
    setState(() {
      _postsFuture = PostRepository().fetchPost(); // Làm mới lại dữ liệu
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Không có bài đăng nào.'));
        } else {
          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  contentPadding: EdgeInsets.all(10),
                  title: Text(post.user.user_name ?? 'Unknown User'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hiển thị nội dung bài đăng
                      Text(post.content ?? 'No content available'),
                      SizedBox(height: 10),
                      // Kiểm tra và hiển thị media (Ảnh hoặc Video)
                      if (post.mediaList.isNotEmpty) ...[
                        for (var media in post.mediaList)
                          media.type == 'video'
                              ? Container(
                                  width: 300,
                                  height: 200,
                                  color: Colors.black,
                                  child: Center(
                                    child: Icon(Icons.play_arrow, color: Colors.white),
                                  ),
                                )
                              : Image.network(
                                  media.mediaUrl,
                                  width: 300,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                      ] else ...[
                        Text('No media available'),
                      ],
                      SizedBox(height: 10),
                      // Hiển thị các thông tin như số lượt thích và bình luận
                      Text('Likes: ${post.likeCount}'),
                      Text('Comments: ${post.commentCount}'),
                      Text('Created At: ${post.createdAt.toLocal()}'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Xử lý việc chỉnh sửa bài đăng
                        _showEditDialog(context, post);
                      } else if (value == 'delete') {
                        // Xử lý việc xóa bài đăng
                        _showDeleteDialog(context, post);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ];
                    },
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  void _showEditDialog(BuildContext context, Post post) {
    // Xử lý hiển thị hộp thoại chỉnh sửa bài đăng
  }

  void _showDeleteDialog(BuildContext context, Post post) {
    // Hiển thị hộp thoại xác nhận xóa bài đăng
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xóa bài đăng'),
          content: Text('Bạn có chắc chắn muốn xóa bài đăng này?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                _deletePost(post.postId); // Gọi phương thức xóa bài đăng
                Navigator.pop(context); // Đóng hộp thoại
              },
              child: Text('Xóa'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng hộp thoại khi hủy
              },
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }
}


class UserDetailScreen extends StatelessWidget {
  final String userName;
  final String email;
  final String userId;

  UserDetailScreen({
    required this.userName,
    required this.email,
    required this.userId,
  });

  void _banUser(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận"),
        content: Text("Bạn có chắc chắn muốn cấm người dùng $userName không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Hủy"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Đóng dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Người dùng $userName đã bị cấm.")),
              );
            },
            child: Text("Đồng ý"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chi tiết người dùng"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color(0xFF00BFA5),
      ),
      body: Column(
        children: [
          // Thông tin người dùng sát phía trên
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "ID: $userId",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Nút cấm người dùng ở cuối màn hình
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _banUser(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                "Cấm người dùng",
                style: TextStyle(fontSize: 16, color: kWhite),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Cập nhật trong UserCard để điều hướng đến UserDetailScreen
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
        onTap: () {
          // Điều hướng đến UserDetailScreen khi bấm vào người dùng
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailScreen(
                userName: userName,
                email: email,
                userId: "User-$index", // Giả lập User ID
              ),
            ),
          );
        },
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Post post;

  PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hiển thị tên người dùng và thời gian tạo
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(post.user.avatar_url),
                ),
                SizedBox(width: 8.0),
                Text(post.user.user_name, style: TextStyle(fontWeight: FontWeight.bold)),
                Spacer(),
                Text(
                  '${post.createdAt.day}-${post.createdAt.month}-${post.createdAt.year}',
                  style: TextStyle(fontSize: 12.0, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 8.0),

            // Hiển thị nội dung bài đăng
            Text(post.content, style: TextStyle(fontSize: 16.0)),

            // Hiển thị media nếu có
            if (post.mediaList.isNotEmpty)
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: post.mediaList.length,
                  itemBuilder: (context, index) {
                    final media = post.mediaList[index];
                    return media.isImage
                        ? Image.network(media.mediaUrl)
                        : VideoWidget(mediaUrl: media.mediaUrl);
                  },
                ),
              ),
            SizedBox(height: 8.0),

            // Hiển thị số lượng like và comment
            Row(
              children: [
                Icon(Icons.thumb_up_alt_outlined, size: 20, color: Colors.blue),
                SizedBox(width: 4.0),
                Text('${post.likeCount} Likes', style: TextStyle(fontSize: 14.0)),
                SizedBox(width: 16.0),
                Icon(Icons.comment_outlined, size: 20, color: Colors.green),
                SizedBox(width: 4.0),
                Text('${post.commentCount} Comments', style: TextStyle(fontSize: 14.0)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// Nếu có phương tiện video
class VideoWidget extends StatelessWidget {
  final String mediaUrl;

  VideoWidget({required this.mediaUrl});

  @override
  Widget build(BuildContext context) {
    // Ví dụ đơn giản là hiển thị URL video
    return Container(
      color: Colors.black,
      child: Center(
        child: Text('Video Player (URL: $mediaUrl)', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
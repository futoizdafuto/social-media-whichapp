import 'package:flutter/material.dart';
import 'package:socially_app_flutter_ui/screens/profile/profilefollow_screen.dart';
import '../../services/FollowServices.dart'; // Import FollowService

class Follower {
  final String name;
  final String subtitle;
  final String profileImageUrl;
  bool isFollowing;
  final List<String> followingList;
  final List<String> followedList;

  Follower({
    required this.name,
    required this.subtitle,
    required this.profileImageUrl,

    this.isFollowing = false,
    this.followingList = const [],
    this.followedList = const [],
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      name: json['name'] ?? '',
      subtitle: json['subtitle'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      followingList: List<String>.from(json['following'] ?? []),
      followedList: List<String>.from(json['followed'] ?? []),
    );
  }
}

class FollowerListScreen extends StatefulWidget {
  final String title;
  final List<Follower> followers;
  final List<Follower> suggestedUsers;
  final bool showFollowButton;
  final List<String> followingList; // Add this parameter

  const FollowerListScreen({
    Key? key,
    required this.title,
    required this.followers,
    required this.suggestedUsers,
    this.showFollowButton = true,
    required this.followingList, // Initialize this parameter
  }) : super(key: key);

  @override
  _FollowerListScreenState createState() => _FollowerListScreenState();
}


class _FollowerListScreenState extends State<FollowerListScreen> {
  final FollowService _followService = FollowService();
  TextEditingController _searchController = TextEditingController();
  List<Follower> _filteredFollowers = [];

  @override
  void initState() {
    super.initState();
    _filteredFollowers = widget.followers;  // Initialize with the full list
    _searchController.addListener(_filterFollowers);  // Listen for changes in search input
  }

  // Function to filter followers based on the search input
  void _filterFollowers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFollowers = widget.followers
          .where((follower) =>
      follower.name.toLowerCase().contains(query) ||
          follower.subtitle.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _toggleFollow(Follower follower) async {
    if (!widget.showFollowButton) return;

    // Kiểm tra nếu tài khoản trong following_list và followed_list có trùng nhau
    final isFollowing = widget.followingList.contains(follower.name);

    // Nếu đã theo dõi thì thực hiện unfollow
    if (isFollowing) {
      final result = await _followService.unfollowUser(follower.name);
      if (result['status'] == 'success') {
        setState(() {
          widget.followingList.remove(follower.name); // Xóa khỏi danh sách following
          follower.isFollowing = false; // Cập nhật trạng thái theo dõi
        });
      } else {
        _showErrorDialog(result['message']);
      }
    } else {
      // Nếu chưa theo dõi thì thực hiện follow
      final result = await _followService.followUser(follower.name);
      if (result['status'] == 'success') {
        setState(() {
          widget.followingList.add(follower.name); // Thêm vào danh sách following
          follower.isFollowing = true; // Cập nhật trạng thái theo dõi
        });
      } else {
        _showErrorDialog(result['message']);
      }
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showUserInfoModal(Follower follower) async {
    final followService = FollowService();
    final userData = await followService.getFollowUser(follower.name);

    if (userData['status'] == 'success') {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(horizontal: 16.0),
            contentPadding: EdgeInsets.all(16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            title: Text(
              follower.name,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Đang theo dõi: ${userData['following_count']}',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  'Được theo dõi: ${userData['followed_count']}',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  _toggleFollow(follower);
                  Navigator.of(context).pop();
                },
                child: Text(follower.isFollowing ? 'Bỏ theo dõi' : 'Theo dõi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: follower.isFollowing ? Colors.grey : Colors.blue,
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Handle error if the user data fetch fails
      print('Error fetching user data: ${userData['message']}');
    }
  }

  Widget _buildFollowerTile(Follower follower) {
    // Kiểm tra nếu người dùng đã theo dõi hay chưa
    bool isFollowing = widget.followingList.contains(follower.name);

    return GestureDetector(
      onTap: () => _showUserInfoModal(follower),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            // Khi bấm vào ảnh đại diện, hiển thị modal thông tin người dùng
            _showUserInfoModal(follower);
          },
          child: CircleAvatar(
            backgroundImage: NetworkImage(follower.profileImageUrl),
          ),
        ),
        title: GestureDetector(
          onTap: () => _navigateToProfile(follower),
          child: Text(
            follower.name,
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        subtitle: Text(follower.subtitle),
        trailing: widget.showFollowButton
            ? ElevatedButton(
          onPressed: () => _toggleFollow(follower), // Thực hiện toggle follow/unfollow
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey : Colors.blue,
          ),
          child: Text(isFollowing ? 'Đã theo dõi' : 'Theo dõi'),
        )
            : null,
      ),
    );
  }


  // Define _navigateToProfile method here
  void _navigateToProfile(Follower follower) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileFollowScreen(
          username: follower.name, // Pass the username to ProfileFollowScreen
          followingList: follower.followingList,
          followedList: follower.followedList,
        ),  // Pass the full data
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            // Suggestions list for searching
            if (_searchController.text.isNotEmpty) ...[
              Expanded(
                child: ListView(
                  children: _filteredFollowers.map((follower) {
                    return _buildFollowerTile(follower);
                  }).toList(),
                ),
              ),
            ] else ...[
              // Default list when search text is empty
              Expanded(
                child: ListView(
                  children: [
                    ...widget.followers.map((follower) => _buildFollowerTile(follower)),
                    if (widget.suggestedUsers.isNotEmpty) ...[
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Gợi ý cho bạn',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      ...widget.suggestedUsers.map((user) => _buildFollowerTile(user)),
                    ]
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

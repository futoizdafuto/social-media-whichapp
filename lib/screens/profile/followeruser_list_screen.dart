import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socially_app_flutter_ui/screens/profile/profile_screen.dart';
import 'package:socially_app_flutter_ui/screens/profile/profilefollow_screen.dart';
import 'package:socially_app_flutter_ui/services/FollowServices.dart';
import 'follower_list_screen.dart';

class FollowUserListScreen extends StatefulWidget {
  final String title;
  final List<Follower> followers;

  const FollowUserListScreen({
    Key? key,
    required this.title,
    required this.followers,
    required List suggestedUsers,
    required bool showFollowButton,
    required List followingList,
  }) : super(key: key);

  @override
  _FollowUserListScreenState createState() => _FollowUserListScreenState();
}

class _FollowUserListScreenState extends State<FollowUserListScreen> {
  final FollowService _followService = FollowService();
  TextEditingController _searchController = TextEditingController();
  List<Follower> _filteredFollowers = [];
  String? _currentUserName; // Store current logged-in username
  List<String> _loggedInUserFollowing = []; // List to store the logged-in user's following list

  @override
  void initState() {
    super.initState();
    _getRealUserName(); // Get username from FlutterSecureStorage
    _filteredFollowers = widget.followers; // Initialize with all followers
    _searchController.addListener(_filterFollowers); // Search filter
  }

  // Get logged-in username from FlutterSecureStorage
  Future<void> _getRealUserName() async {
    final storage = FlutterSecureStorage();
    String? username = await storage.read(key: 'realuserName'); // Read username
    setState(() {
      _currentUserName = username;
    });

    // Remove logged-in user from followers list if present
    if (_currentUserName != null) {
      setState(() {
        _filteredFollowers = widget.followers
            .where((follower) => follower.name != _currentUserName)
            .toList(); // Remove the current user from the followers list
      });
      _getLoggedInUserFollowing(); // Fetch the logged-in user's following list
    }
  }

  // Fetch the logged-in user's following list
  Future<void> _getLoggedInUserFollowing() async {
    if (_currentUserName != null) {
      final followData = await _followService.getFollowUser(_currentUserName!);
      if (followData['status'] == 'success') {
        setState(() {
          _loggedInUserFollowing = List<String>.from(followData['following_list']);
        });
      }
    }
  }

  // Filter followers based on the search query and the following status
  void _filterFollowers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      // Filter out followers who are not in the following list or who don't match the search query
      _filteredFollowers = widget.followers
          .where((follower) =>
      _loggedInUserFollowing.contains(follower.name) && // Only show users that are followed by the current user
          (follower.name.toLowerCase().contains(query) || // Match the search query
              follower.subtitle.toLowerCase().contains(query)))
          .toList();
      // Remove the logged-in user from the search results if it's being shown
      if (_currentUserName != null) {
        _filteredFollowers = _filteredFollowers
            .where((follower) => follower.name != _currentUserName)
            .toList();
      }
    });
  }

  // Handle follow/unfollow actions
  Future<void> _toggleFollow(Follower follower) async {
    setState(() {
      // Toggle the local state of the follower (this controls UI only)
      follower.isFollowing = !follower.isFollowing;
    });

    final targetUsername = follower.name;

    if (!_loggedInUserFollowing.contains(targetUsername)) {
      // If the selected user is not in the following list of the logged-in user, follow them
      final result = await _followService.followUser(targetUsername);
      if (result['status'] == 'success') {
        setState(() {
          // After successfully following, add to logged-in user's following list
          if (!_loggedInUserFollowing.contains(targetUsername)) {
            _loggedInUserFollowing.add(targetUsername);
          }
        });
      } else {
        // If there is an error, revert the local state
        setState(() {
          follower.isFollowing = false;
        });
        _showErrorDialog(result['message']);
      }
    } else {
      // If the user is already in the following list, unfollow them
      final result = await _followService.unfollowUser(targetUsername);
      if (result['status'] == 'success') {
        setState(() {
          // After successfully unfollowing, remove from logged-in user's following list
          _loggedInUserFollowing.remove(targetUsername);
        });
      } else {
        // If there is an error, revert the local state
        setState(() {
          follower.isFollowing = true;
        });
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

  void _navigateToProfile(Follower follower) {
    if (_loggedInUserFollowing.contains(follower.name)) {
      // Navigate to ProfileFollowScreen if the user is in the following list
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileFollowScreen(
            username: follower.name, // Pass the username to ProfileFollowScreen
            followingList: follower.followingList, // Pass the following list
            followedList: follower.followedList, // Pass the followed list
          ),
        ),
      );
    } else {
      // Otherwise, navigate to ProfileScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(username: follower.name),
        ),
      );
    }
  }

  Widget _buildFollowerTile(Follower follower) {
    // Check if the follower is in the logged-in user's following list
    bool isFollowing = _loggedInUserFollowing.contains(follower.name);

    return GestureDetector(
      onTap: () => _showUserInfoModal(follower),
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
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
        trailing: ElevatedButton(
          onPressed: () => _toggleFollow(follower),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey : Colors.blue,
          ),
          child: Text(isFollowing ? 'Đã theo dõi' : 'Theo dõi'),
        ),
      ),
    );
  }

  Future<void> _showUserInfoModal(Follower follower) async {
    final userData = await _followService.getFollowUser(follower.name);

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
      print('Error fetching user data: ${userData['message']}');
    }
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
            // Search bar at the top
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

            // Display logged-in user's account if available
            if (_currentUserName != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                    NetworkImage('https://example.com/your_profile_image_url'), // Profile image URL for logged-in user
                  ),
                  title: Text(
                    _currentUserName!,
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  subtitle: Text('Tài khoản đang đăng nhập'),
                  onTap: () {
                    // When tapped, navigate to their profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(username: _currentUserName!),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Display the remaining followers list after filtering
            Expanded(
              child: ListView(
                children: _filteredFollowers.map((follower) => _buildFollowerTile(follower)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


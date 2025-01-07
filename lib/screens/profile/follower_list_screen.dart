import 'package:flutter/material.dart';
import '../../services/FollowServices.dart'; // Import FollowService

class Follower {
  final String name;
  final String subtitle;
  final String profileImageUrl;
  bool isFollowing; // Make this mutable

  Follower({
    required this.name,
    required this.subtitle,
    required this.profileImageUrl,
    this.isFollowing = false, // Default value is false (not following)
  });

  factory Follower.fromJson(Map<String, dynamic> json) {
    return Follower(
      name: json['name'] ?? '',
      subtitle: json['subtitle'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
    );
  }
}

class FollowerListScreen extends StatefulWidget {
  final String title;
  final List<Follower> followers;
  final List<Follower> suggestedUsers;
  final bool showFollowButton; // New parameter

  const FollowerListScreen({
    Key? key,
    required this.title,
    required this.followers,
    required this.suggestedUsers,
    this.showFollowButton = true, // Default is true (show Follow button)
  }) : super(key: key);

  @override
  _FollowerListScreenState createState() => _FollowerListScreenState();
}

class _FollowerListScreenState extends State<FollowerListScreen> {
  final FollowService _followService = FollowService(); // Instance of FollowService

  // Method to update the follower list when a user follows/unfollows someone
  Future<void> _toggleFollow(Follower follower) async {
    if (!widget.showFollowButton) return; // If follow button is not visible, do nothing

    setState(() {
      follower.isFollowing = !follower.isFollowing; // Toggle the follow state
    });

    final targetUsername = follower.name; // The target user to follow/unfollow

    if (follower.isFollowing) {
      // If the user is now following, call followUser
      final result = await _followService.followUser(targetUsername);
      if (result['status'] == 'error') {
        // If the follow fails, revert the state
        setState(() {
          follower.isFollowing = false;
        });
        _showErrorDialog(result['message']);
      }
    } else {
      // If the user is now unfollowing, call unfollowUser
      final result = await _followService.unfollowUser(targetUsername);
      if (result['status'] == 'error') {
        // If the unfollow fails, revert the state
        setState(() {
          follower.isFollowing = true;
        });
        _showErrorDialog(result['message']);
      }
    }
  }

  // Show error dialog
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),

            // Followers List
            Expanded(
              child: ListView(
                children: [
                  ...widget.followers.map((follower) => _buildFollowerTile(follower)),
                  Divider(),
                  if (widget.suggestedUsers.isNotEmpty)
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build a single follower tile
  Widget _buildFollowerTile(Follower follower) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(follower.profileImageUrl),
      ),
      title: Text(follower.name),
      subtitle: Text(follower.subtitle),
      trailing: widget.showFollowButton
          ? ElevatedButton(
        onPressed: () => _toggleFollow(follower),
        style: ElevatedButton.styleFrom(
          backgroundColor: follower.isFollowing ? Colors.grey : Colors.blue,
        ),
        child: Text(follower.isFollowing ? 'Đã theo dõi' : 'Theo dõi'),
      )
          : null, // Don't show button if showFollowButton is false
    );
  }
}


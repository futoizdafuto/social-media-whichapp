import 'package:flutter/material.dart';

class Follower {
  final String name;
  final String subtitle;
  final String profileImageUrl;
  bool isFollowing; // Change to mutable

  Follower({
    required this.name,
    required this.subtitle,
    required this.profileImageUrl,
    this.isFollowing = false, // Default value
  });
}

class FollowerListScreen extends StatefulWidget {
  final String title;
  final List<Follower> followers;
  final List<Follower> suggestedUsers;

  const FollowerListScreen({
    Key? key,
    required this.title,
    required this.followers,
    required this.suggestedUsers,
  }) : super(key: key);

  @override
  _FollowerListScreenState createState() => _FollowerListScreenState();
}

class _FollowerListScreenState extends State<FollowerListScreen> {
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Gợi ý cho bạn',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        )),
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
      trailing: ElevatedButton(
        onPressed: () {
          setState(() {
            // Toggle follow state and update button text
            if (follower.isFollowing) {
              follower.isFollowing = false; // Unfollow
            } else {
              follower.isFollowing = true; // Follow
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: follower.isFollowing ? Colors.grey : Colors.blue,
        ),
        child: Text(follower.isFollowing ? 'Đã theo dõi' : 'Theo dõi'),
      ),
    );
  }
}

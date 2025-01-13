
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socially_app_flutter_ui/screens/profile/profile_screen.dart';

class Postinprofilescreen extends StatelessWidget {
  final String username = "pttgenzit";
  final String profileImage =
      "https://via.placeholder.com/150"; // Ảnh đại diện giả định
  final String caption = "So lit";
  final String timeAgo = "3 ngày trước";
  final int likes = 1;
  final int comments = 1;
  final String postImage;

  Postinprofilescreen({Key? key, required this.postImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Bài viết",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      username,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.black),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Post Image
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(postImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.favorite_border, color: Colors.black),
                  SizedBox(width: 15),
                  Icon(Icons.comment, color: Colors.black),
                  SizedBox(width: 15),
                  Icon(Icons.send, color: Colors.white),
                  Spacer(),
                  Icon(Icons.bookmark_border, color: Colors.black),
                ],
              ),
            ),

            // Likes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "Có ry_n6262 thích",
                style: TextStyle(color: Colors.black),
              ),
            ),

            // Caption
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$username ",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(
                      text: caption,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),

            // Time Ago
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Text(
                timeAgo,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),

            // Show Image URL

          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProfileScreen(username: '',),
  ));
}
import 'package:flutter/material.dart';

class FollowerListScreen extends StatelessWidget {
  final String title;
  final List<String> followers;

  const FollowerListScreen({
    Key? key,
    required this.title,
    required this.followers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: followers.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(followers[index]),
            // Thêm chức năng click để mở trang hồ sơ người dùng nếu cần
          );
        },
      ),
    );
  }
}

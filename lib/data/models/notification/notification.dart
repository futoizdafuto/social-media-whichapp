import 'dart:convert';
import 'package:socially_app_flutter_ui/data/models/post/post.dart';

import '../user/user.dart';

class NotificationA {
  final String username;
  final String message;
  final Post post;
  final bool isRead;
  final DateTime createdAt;

  NotificationA({
    required this.username,
    required this.message,
    required this.post,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationA.fromJson(Map<String, dynamic> json) {
    return NotificationA(
      username: json['username'] ?? '',
      message: json['message'] ?? '',
      post: Post.fromJson(json['post'] ?? {}), // Ánh xạ object `post`
      isRead: json['isRead']?.toLowerCase() == 'true',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

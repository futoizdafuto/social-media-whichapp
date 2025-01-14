import 'dart:convert';
import 'package:socially_app_flutter_ui/data/models/post/post.dart';

import '../user/user.dart';

class Comment {
  final Post? post; // Cho phép null
  final User user;
  final String content;
  final String createdAt;

  Comment({
    required this.post,
    required this.user,
    required this.content,
    required this.createdAt,
  });

  // Tạo một đối tượng Comment từ JSON
  // factory Comment.fromJson(Map<String, dynamic> json) {
  //   return Comment(
  //     post: json['post'] != null ? Post.fromJson(json['post']) : Post.defaultPost(),
  //     user: json['user'] != null ? User.fromJson(json['user']) : User.defaultUser(),
  //     content: json['content'] ?? '',
  //     createdAt: json['created_at'] != null
  //         ? DateTime.parse(json['created_at'])
  //         : DateTime.now(),
  //   );
  // }

  factory Comment.fromJson(Map<String, dynamic> json) {
    try {
      // Cố gắng giải mã JSON
      return Comment(
        post: json['post'] != null ? Post.fromJson(json['post']) : Post.defaultPost(),
        user: json['user'] != null ? User.fromJson(json['user']) : User.defaultUser(),
        content: json['content'] ?? 'No content', // Tránh null
        createdAt: json['createdAt'] ?? 'Unknow', // Tránh null
      );
    } catch (e) {
      // Bắt lỗi nếu có bất kỳ vấn đề gì trong quá trình giải mã JSON
      print("Error parsing comment: $e");
      // Trả về đối tượng Comment với dữ liệu mặc định khi có lỗi
      return Comment(post:Post.fromJson(json['post']) ,user:User.fromJson(json['user']) ,content: json['content'], createdAt: json['createdAt']);
    }
  }

  // Chuyển đổi đối tượng Comment thành JSON
  Map<String, dynamic> toJson() {
    return {
      'post': post?.toJson(), // Sử dụng dấu ? để kiểm tra null
      'user': user.toJson(),
      'content': content,
      'created_at': createdAt,
    };
  }
}
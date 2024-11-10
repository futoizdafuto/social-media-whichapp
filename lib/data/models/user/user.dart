import 'dart:core';
import 'package:socially_app_flutter_ui/data/models/post/post.dart';

class User {
  final int user_id;
  final String avatar_url;
  final String user_name;
  final String password;
  final String email;
  final String name;
  final List<Post> post;

  static User defaultUser() {
    return User(user_name: 'Unknown', avatar_url: 'default_avatar_url.png', user_id: 0, password: '', email: '', name: '', post: []);
  }
  User(
      {required this.user_id,
      required this.avatar_url,
      required this.user_name,
      required this.password,
      required this.email,
      required this.name,
      required this.post});

      

// tọa 1 đối tượng user từ JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
        user_id: json['user_id'],
        avatar_url: json['avatar_url'],
        user_name: json['username'],
        password: json['password'],
        email: json['email'],
        name: json['name'],
        post: json['post'] != null
            ? List<Post>.from(json['post'].map((post) => Post.fromJson(json)))
            : []);
  }

// chuyển đối tượng User thành Json
  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'avatar_url': avatar_url,
      'user_name': user_name,
      'password': password,
      'email': email,
      'name': name,
      'post': post.map((post) => post.toJson()).toList(),
    };
  }
}

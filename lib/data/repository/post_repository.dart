import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socially_app_flutter_ui/data/models/user/user.dart';
import '../models/post/post.dart';

class PostRepository {
  // final String api_url = 'https://10.0.2.2:8443/api/posts';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String api_url = 'https://192.168.1.40:8443/api/posts';

//   Future<List<Post>> fetchPost() async {
//   String? token = await _storage.read(key: 'token');
//   if (token == null) {
//     // Thực hiện re-login hoặc xử lý khi không có token
//     return [];
//   }

//   try {
//     final response = await http.get(
//       Uri.parse(api_url),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((json) => Post.fromJson(json)).toList();
//     } else if (response.statusCode == 401) {
//       // Xử lý lỗi 401 bằng cách thực hiện re-login hoặc cập nhật token mới
//       print("Token không hợp lệ, thực hiện re-login...");
//     }
//     throw Exception("Failed to load posts. Status code: ${response.statusCode}");
//   } catch (e) {
//     print('Error: $e');
//     return [];
//   }
// }

  Future<List<Post>> fetchPost() async {
    String? token = await _storage.read(key: 'token');
    if (token == null) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse(api_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Giải mã từng bài đăng thành đối tượng Post
        return data.map((json) {
          // Giải mã user nếu có
          var userJson = json['user'];
          var user = User(
            user_id: userJson['user_id'],
            user_name: userJson['username'],
            avatar_url: '',
            password: '',
            email: '',
            name: '',
            post: [],
          );

          // Giải mã mediaList nếu có
          var mediaListJson = json['mediaList'] as List;
          List<Media> mediaList = mediaListJson
              .map((mediaJson) => Media.fromJson(mediaJson))
              .toList();

          return Post(
            postId: json['post_id'],
            content: json['content'],
            mediaList: mediaList,
            createdAt: DateTime.parse(json['created_at']),
            user: user,
          );
        }).toList();
      } else if (response.statusCode == 401) {
        print("Token không hợp lệ, thực hiện re-login...");
      }
      throw Exception(
          "Failed to load posts. Status code: ${response.statusCode}");
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }
}

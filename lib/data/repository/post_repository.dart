import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socially_app_flutter_ui/data/models/user/user.dart';
import '../models/post/post.dart';
import '../models/post/comment.dart';

class PostRepository {
  // final String api_url = 'https://10.0.2.2:8443/api/posts';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String api_url = 'https://192.168.1.6:8443/api/posts';

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
          print(json);
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
            user: user,
            content: json['content'],
            mediaList: mediaList,
            createdAt: DateTime.parse(json['created_at']),
            likeCount: json['like_count'],
            commentCount: json['comment_count'],
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

Future<Map<String, dynamic>> likePost(int postId) async {
  String? token = await _storage.read(key: 'token');
  String? userId = await _storage.read(key: 'userId');
  //if (token == null) return 'Unauthorized';
    final response = await http.post(
      Uri.parse('$api_url/$postId/like'),
      headers: {'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      try {
        // Thử parse JSON
        return jsonDecode(response.body);
      } catch (e) {
        // Nếu không phải JSON, trả về thông báo dạng chuỗi
        return {'message': response.body};
      }
    } else {
      throw Exception('Failed to like post');
    }
  }

  Future<Map<String, dynamic>> unlikePost(int postId) async {
    String? token = await _storage.read(key: 'token');
    String? userId = await _storage.read(key: 'userId');
    final response = await http.post(
      Uri.parse('$api_url/$postId/unlike'),
      headers: {'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'},
      body: jsonEncode({'user_id': userId}),
    );

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return {'message': response.body};
      }
    } else {
      throw Exception('Failed to unlike post');
    }
  }

  Future<bool> getLikeStatus(int postId) async {
    String? token = await _storage.read(key: 'token');
    String? userId = await _storage.read(key: 'userId');
    final url = '$api_url/posts/$postId/checkLike';
    print('Calling API: $url'); 
    try {
      final response = await http.post(
      Uri.parse('$api_url/$postId/checkLike'),
      headers: {'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'},
      body: jsonEncode({'user_id': userId}),
    );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isLiked'] as bool; // Lấy giá trị isLiked từ JSON
      } else {
        throw Exception('Failed to fetch like status: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching like status: $error');
      return false; // Trả về false khi có lỗi
    }
  }

  Future<List<Comment>> getCommentsByPost(int postId) async {
  String? token = await _storage.read(key: 'token');

  final response = await http.get(
    Uri.parse('$api_url/$postId/allcomments'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = jsonDecode(response.body);
    print(jsonResponse); // In ra để kiểm tra cấu trúc
    // Lấy số lượng bình luận từ thông tin post
    int commentCount = jsonResponse.isNotEmpty
        ? jsonResponse.first['post']['commentCount'] ?? 0
        : 0;

    print('Comment count: $commentCount'); // In kiểm tra
    jsonResponse.forEach((comment) {
      print("User: ${comment['user'] ?? 'No user'}");
      print("Post: ${comment['post'] ?? 'No post'}");
      print("Content: ${comment['content'] ?? 'No content'}");
      print("Created At: ${comment['createdAt'] ?? 'No createdAt'}");
      });
    // Chuyển đổi danh sách JSON thành danh sách Comment
    return jsonResponse.map((comment) => Comment.fromJson(comment)).toList().reversed.toList();
  } else {
    throw Exception('Failed to load comments');
  }
} 

Future<String> addComment(int postId, String content) async {
  String? token = await _storage.read(key: 'token');
  String? userId = await _storage.read(key: 'userId');
  final url = Uri.parse('$api_url/$postId/comments');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded', // Thay đổi Content-Type
      'Authorization': 'Bearer $token',
    },
    body: 'user_id=$userId&content=$content', // Gửi dữ liệu URL-encoded
  );

  if (response.statusCode == 200) {
    return response.body; // Trả về chuỗi phản hồi từ backend
  } else {
    throw Exception('Failed to add comment: ${response.body}');
  }
}


}

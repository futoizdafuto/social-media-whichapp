import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socially_app_flutter_ui/data/models/user/user.dart';
import '../models/post/post.dart';

class PostRepository {
  // final String api_url = 'https://10.0.2.2:8443/api/posts';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String api_url = 'https://192.168.100.228:8443/api/posts';
  // final String api_url = 'https://10.150.105.205:8443/api/posts';
  

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
// 
Future<String?> _getValidToken() async {
    final token = await _storage.read(key: 'token');
    return token;  // Just return the token from storage if it exists
  }

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
    Future<Map<String, dynamic>> getCountPostByUsername() async {
    try {
      // Kiểm tra nếu người dùng không tồn tại hoặc chưa đăng nhập
      final realUserName = await _storage.read(key: 'realuserName');
      if (realUserName == null) {
        return {
          'status': 'error',
          'message': 'User is not logged in. Please log in first.',
        };
      }

      // Lấy token hợp lệ
      String? token = await _getValidToken();
      if (token == null) {
        return {
          'status': 'error',
          'message': 'Failed to get valid token. Please log in again.',
        };
      }

      // Truy vấn từ API với username và token
      final url = Uri.parse('$api_url/sizeby-user?username=$realUserName');  // Chỉnh sửa URL API của bạn
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      // Xử lý phản hồi từ server
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData != null && responseData['status'] == 'success') {
          int postCount = responseData['post_count'] ?? 0;  // Lấy giá trị 'post_count' từ phản hồi

          return {
            'status': 'success',
            'message': 'Successfully fetched post count.',
            'post_count': postCount,  // Trả về số lượng bài viết
          };
        } else {
          return {
            'status': 'error',
            'message': responseData?['message'] ?? 'Failed to fetch post count.',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'HTTP error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'An error occurred: $e',
      };
    }
  }
  Future<Map<String, dynamic>> getImagesByUsername() async {
    try {
      // Kiểm tra nếu người dùng không tồn tại hoặc chưa đăng nhập
      final realUserName = await _storage.read(key: 'realuserName');
      if (realUserName == null) {
        return {
          'status': 'error',
          'message': 'User is not logged in. Please log in first.',
        };
      }

      // Lấy token hợp lệ
      String? token = await _getValidToken();
      if (token == null) {
        return {
          'status': 'error',
          'message': 'Failed to get valid token. Please log in again.',
        };
      }

      // Truy vấn API với username và token
      final url = Uri.parse('$api_url/image?username=$realUserName'); // URL API cho việc lấy ảnh
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      // Xử lý phản hồi từ server
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData != null && responseData.isNotEmpty) {
          List<Map<String, dynamic>> imageList = [];

          // Duyệt qua từng phần tử trong response để trích xuất URL ảnh và created_at
          for (var item in responseData) {
            if (item['image_url'] != null && item['created_at'] != null) {
              imageList.add({
                'image_url': item['image_url'],
                'created_at': item['created_at'],
              });
            }
          }

          // Sắp xếp danh sách ảnh theo 'created_at' từ mới nhất đến cũ nhất
          imageList.sort((a, b) => DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));

          return {
            'status': 'success',
            'message': 'Successfully fetched image list.',
            'image_list': imageList,  // Trả về danh sách ảnh đã sắp xếp
          };
        } else {
          return {
            'status': 'error',
            'message': 'No images found for this user.',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'HTTP error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'An error occurred: $e',
      };
    }
  }





  Future<Map<String, dynamic>> getPostsByUsername() async {
    try {
      // Đọc realUserName từ storage
      final realUserName = await _storage.read(key: 'realuserName');
      if (realUserName == null) {
        return {
          'status': 'error',
          'message': 'User is not logged in. Please log in first.',
        };
      }

      // Lấy token hợp lệ từ storage
      String? token = await _storage.read(key: 'token');
      if (token == null) {
        return {
          'status': 'error',
          'message': 'Failed to get valid token. Please log in again.',
        };
      }

      // Tạo URL API để lấy bài post của người dùng theo username
      final url = Uri.parse('$api_url/by-user?username=$realUserName');
      final headers = {
        'Authorization': 'Bearer $token',
      };

      // Gửi yêu cầu HTTP GET đến API
      final response = await http.get(url, headers: headers);

      // Kiểm tra phản hồi từ server
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData != null && responseData['status'] == 'success') {
          // Danh sách bài đăng của người dùng
          List posts = responseData['posts'] ?? [];
          List<Map<String, dynamic>> formattedPosts = [];

          // Duyệt qua từng bài đăng và cấu trúc lại dữ liệu cho dễ sử dụng
          for (var post in posts) {
            // Lấy thông tin người dùng
            var user = post['user'];
            String username = user['username'] ?? 'Unknown User';

            // Lấy thông tin phương tiện
            List<Map<String, dynamic>> mediaList = [];
            if (post['mediaList'] != null) {
              for (var media in post['mediaList']) {
                mediaList.add({
                  'id': media['id'],
                  'url': media['url'],
                  'type': media['type'],
                });
              }
            }

            // Định dạng bài đăng
            formattedPosts.add({
              'post_id': post['post_id'],
              'user': username,
              'content': post['content'],
              'created_at': post['created_at'],
              'mediaList': mediaList, // Thêm media vào bài đăng
            });
          }

          return {
            'status': 'success',
            'message': 'Successfully fetched posts.',
            'posts': formattedPosts, // Trả về danh sách bài đăng đã được định dạng
          };
        } else {
          return {
            'status': 'error',
            'message': responseData?['message'] ?? 'Failed to fetch posts data.',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'HTTP error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'An error occurred: $e',
      };
    }
  }
}


  // void fetch() async {
  //   var url = Uri.parse(
  //       'https://10.51.74.195:8443/uploads/c76a6072-24d1-4df0-9558-022136ff03e4cat1.mp4');

  //   try {
  //     final response = await http.get(url);

  //     if (response.statusCode == 200) {
  //       print('Dữ liệu tải thành công!');
  //     } else {
  //       print('Lỗi: ${response.statusCode}  lõi đây nè');
  //     }
  //   } catch (e) {
  //     print('Lỗi: $e');
  //   }
  // }


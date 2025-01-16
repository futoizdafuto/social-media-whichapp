import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socially_app_flutter_ui/data/models/user/user.dart';
import '../models/post/post.dart';
import 'package:http_parser/http_parser.dart'; // <-- Add this import
import '../models/post/post.dart';
import '../models/post/comment.dart';
class PostRepository {
  // final String api_url = 'https://10.0.2.2:8443/api/posts';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  // final String api_url = 'https://10.0.172.216:8443/api/posts';
    //  final String api_url = 'https://192.168.1.8:8443/api/posts';
           static const api_url = 'https://192.168.1.6:8443/api/posts';
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
// }
  Future<String?> _getValidToken() async {
    final token = await _storage.read(key: 'token');
    return token; // Just return the token from storage if it exists
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
            avatar_url: userJson['avatar_url'],
            password: '',
            email: '',
            name: userJson['name'],
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
      final url = Uri.parse(
          '$api_url/sizeby-user?username=$realUserName'); // Chỉnh sửa URL API của bạn
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      // Xử lý phản hồi từ server
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData != null && responseData['status'] == 'success') {
          int postCount = responseData['post_count'] ??
              0; // Lấy giá trị 'post_count' từ phản hồi

          return {
            'status': 'success',
            'message': 'Successfully fetched post count.',
            'post_count': postCount, // Trả về số lượng bài viết
          };
        } else {
          return {
            'status': 'error',
            'message': responseData?['message'] ??
                'Failed to fetch post count.',
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

  Future<Map<String, dynamic>> getCountPostByUsername2(String username) async {
    try {
      // Kiểm tra nếu người dùng không tồn tại hoặc chưa đăng nhập
      if (username.isEmpty) {
        return {
          'status': 'error',
          'message': 'Username is required.',
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
      final url = Uri.parse(
          '$api_url/sizeby-user?username=$username'); // Chỉnh sửa URL API của bạn
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);

      // Xử lý phản hồi từ server
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData != null && responseData['status'] == 'success') {
          int postCount = responseData['post_count'] ??
              0; // Lấy giá trị 'post_count' từ phản hồi

          return {
            'status': 'success',
            'message': 'Successfully fetched post count.',
            'post_count': postCount, // Trả về số lượng bài viết
          };
        } else {
          return {
            'status': 'error',
            'message': responseData?['message'] ??
                'Failed to fetch post count.',
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
      final url = Uri.parse(
          '$api_url/image?username=$realUserName'); // URL API cho việc lấy ảnh
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
          imageList.sort((a, b) =>
              DateTime.parse(b['created_at']).compareTo(
                  DateTime.parse(a['created_at'])));

          return {
            'status': 'success',
            'message': 'Successfully fetched image list.',
            'image_list': imageList, // Trả về danh sách ảnh đã sắp xếp
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

  Future<Map<String, dynamic>> getImagesByUsername2(String username) async {
    try {
      // Kiểm tra nếu người dùng không tồn tại hoặc chưa đăng nhập
      if (username.isEmpty) {
        return {
          'status': 'error',
          'message': 'Username is required.',
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
      final url = Uri.parse(
          '$api_url/image?username=$username'); // URL API cho việc lấy ảnh
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
          imageList.sort((a, b) =>
              DateTime.parse(b['created_at']).compareTo(
                  DateTime.parse(a['created_at'])));

          return {
            'status': 'success',
            'message': 'Successfully fetched image list.',
            'image_list': imageList, // Trả về danh sách ảnh đã sắp xếp
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
        final List<dynamic> responseData = json.decode(response.body);

        // Kiểm tra nếu không có bài đăng
        if (responseData.isEmpty) {
          return {
            'status': 'error',
            'message': 'No posts found for this user.',
          };
        }

        // Danh sách bài đăng đã được định dạng
        List<Map<String, dynamic>> formattedPosts = responseData.map((post) {
          // Lấy thông tin người dùng
          final user = post['user'] ?? {};
          final username = user['username'] ?? 'Unknown User';
          final userId = user['user_id'];

          // Lấy thông tin phương tiện
          final mediaList = (post['mediaList'] ?? []).map((media) {
            return {
              'id': media['id'],
              'url': media['url'],
              'type': media['type'],
            };
          }).toList();

          // Trả về bài đăng đã được định dạng
          return {
            'post_id': post['post_id'],
            'content': post['content'],
            'created_at': post['created_at'],
            'user': {
              'user_id': userId,
              'username': username,
            },
            'mediaList': mediaList,
          };
        }).toList();

        return {
          'status': 'success',
          'message': 'Successfully fetched posts.',
          'posts': formattedPosts,
        };
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

  Future<Map<String, dynamic>> updatePost(int postId, String newContent) async {
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

      // Tạo URL API để cập nhật bài post
      final url = Uri.parse('$api_url/update/$postId');
      final headers = {
        'Authorization': 'Bearer $token',
      };

      // Tạo body dữ liệu để gửi
      final body = {
        'content': newContent,
      };

      // Gửi yêu cầu HTTP PUT đến API
      final response = await http.put(url, headers: headers, body: body);

      // Kiểm tra phản hồi từ server
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Kiểm tra phản hồi xem có thông báo thành công hay không
        if (responseData['status'] == 'success') {
          return {
            'status': 'success',
            'message': 'Post updated successfully.',
          };
        } else {
          return {
            'status': 'error',
            'message': responseData['message'] ?? 'Unknown error occurred.',
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

  Future<Map<String, dynamic>> deletePost(int postId) async {
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

      // Tạo URL API để cập nhật bài post
      final url = Uri.parse('$api_url/delete/$postId');
      final headers = {
        'Authorization': 'Bearer $token',
      };

      // Tạo body dữ liệu để gửi


      // Gửi yêu cầu HTTP PUT đến API
      final response = await http.delete(url, headers: headers);

      // Kiểm tra phản hồi từ server
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Kiểm tra phản hồi xem có thông báo thành công hay không
        if (responseData['status'] == 'success') {
          return {
            'status': 'success',
            'message': 'Post updated successfully.',
          };
        } else {
          return {
            'status': 'error',
            'message': responseData['message'] ?? 'Unknown error occurred.',
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


  Future<Map<String, dynamic>> uploadPost(int userId, List<File> files,
      String content) async {
    try {
      // Ensure the user is logged in and has a valid token
      String? token = await _storage.read(key: 'token');
      if (token == null) {
        return {
          'status': 'error',
          'message': 'Failed to get valid token. Please log in again.',
        };
      }

      // Create the request URL
      final url = Uri.parse('$api_url/upload');

      // Create the multipart request
      var request = http.MultipartRequest('POST', url)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['user_id'] = userId.toString()
        ..fields['content'] = content;

      // Add files to the request
      for (var file in files) {
        var fileExtension = file.path
            .split('.')
            .last;
        String fileType;

        if (fileExtension == 'mp4' || fileExtension == 'mov') {
          fileType = 'video';
        } else {
          fileType = 'image';
        }

        var multipartFile = await http.MultipartFile.fromPath(
          'files', // The field name that the backend expects
          file.path,
          contentType: MediaType(fileType,
              fileExtension), // Determine content type based on file extension
        );

        request.files.add(multipartFile);
      }

      // Send the request
      var response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final responseJson = json.decode(responseData);

        if (responseJson['message'] == 'Post created successfully') {
          return {
            'status': 'success',
            'message': responseJson['message'],
            'post': responseJson['post'], // The post returned from the backend
            'user': responseJson['user'], // User data included in the response
          };
        } else {
          return {
            'status': 'error',
            'message': responseJson['error'] ?? 'Unknown error occurred.',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'HTTP error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'An error occurred: $e',
      };
    }
  }
  Future<Map<String, dynamic>> getAllUsers() async {
    try {
      // Check if the user is logged in by getting the real username
      final realUserName = await _storage.read(key: 'realuserName');
      if (realUserName == null) {
        return {
          'status': 'error',
          'message': 'User is not logged in. Please log in first.',
        };
      }

      // Get a valid token for authorization
      String? token = await _getValidToken();
      if (token == null) {
        return {
          'status': 'error',
          'message': 'Failed to get valid token. Please log in again.',
        };
      }

      // URL to get all users (replace with your actual API endpoint)
      final url = Uri.parse('$api_url/users'); // Adjust to the correct endpoint

      // Headers with Authorization
      final headers = {
        'Authorization': 'Bearer $token',
      };

      // Make GET request to fetch all users
      final response = await http.get(url, headers: headers);

      // Process the response from the server
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData != null && responseData['status'] == 'success') {
          // Parsing the list of users
          List<dynamic> usersList = responseData['users'] ?? [];
          List<Map<String, dynamic>> formattedUsers = [];

          // Loop through users and format the data
          for (var user in usersList) {
            formattedUsers.add({
              "user_id": user["user_id"],
              "avatar_url": user["avatar_url"],
              "username": user["username"],
              "password": user["password"],
              "email": user["email"],
              "name": user["name"],
              "role": {
                "role_id": user["role"]["role_id"],
                "type": user["role"]["type"],
              },
              "private": user["private"],
            });
          }

          return {
            'status': 'success',
            'message': 'Successfully fetched all users.',
            'users': formattedUsers,
          };
        } else {
          return {
            'status': 'error',
            'message': responseData?['message'] ?? 'Failed to fetch users data.',
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
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/post/post.dart';

class PostRepository {
  // final String api_url = 'https://10.0.2.2:8443/api/posts';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String api_url = 'https://192.168.100.141:8443/api/posts';
  

  // Future<List<Post>> fetchPost( Future<String?> token) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse(api_url),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token', // Kèm token vào header
  //       },
  //     );
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body);
  //       return data.map((json) => Post.fromJson(json)).toList();
  //     } else {
  //       throw Exception(
  //           "Failed to load posts. Status code: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print('Error: $e   jadslkdasjasd'); // In lỗi ra console để debug.
  //     return []; // Trả về danh sách rỗng để tránh crash.
  //   }
  // }

  Future<List<Post>> fetchPost() async {
  String? token = await _storage.read(key: 'token');
  if (token == null) {
    // Thực hiện re-login hoặc xử lý khi không có token
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
      return data.map((json) => Post.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      // Xử lý lỗi 401 bằng cách thực hiện re-login hoặc cập nhật token mới
      print("Token không hợp lệ, thực hiện re-login...");
    }
    throw Exception("Failed to load posts. Status code: ${response.statusCode}");
  } catch (e) {
    print('Error: $e');
    return [];
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
}

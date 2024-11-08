import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/post/post.dart';

class PostRepository {
  // final String api_url = 'https://10.0.2.2:8443/api/posts';
  final String api_url = 'https://192.168.149.91:8443/api/posts';

  Future<List<Post>> fetchPost(String token) async {
    try {
      final response = await http.get(
        Uri.parse(api_url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Kèm token vào header
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception(
            "Failed to load posts. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e   jadslkdasjasd'); // In lỗi ra console để debug.
      return []; // Trả về danh sách rỗng để tránh crash.
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

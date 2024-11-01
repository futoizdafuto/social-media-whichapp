import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/post/post.dart';

class PostRepository {
  final String api_url = 'http://10.0.2.2:8080/api/posts';

  Future<List<Post>> fetchPost() async {
    try {
      final response = await http.get(Uri.parse(api_url)); 
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
}

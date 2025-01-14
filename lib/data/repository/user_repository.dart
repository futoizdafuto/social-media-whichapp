import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/user/user.dart';

class UserRepository {
  // final String api_url = 'https://192.168.1.10:8443/api/users';
  

  // Future<List<User>> fetchUser() async {
    
  //   try {
  //     final response = await http.get(Uri.parse(api_url));
  //     print('Response status: ${response.statusCode}');
  //     print('Response body: ${response.body}'); // In ra body của phản hồi
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body);
  //       return data.map((json) => User.fromJson(json)).toList();
  //     } else {
  //       throw Exception(
  //           "Failed to load user. Status code: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print('Error: $e   '); // In lỗi ra console để debug.
  //     return []; // Trả về danh sách rỗng để tránh crash.
  //   }
  // }
}

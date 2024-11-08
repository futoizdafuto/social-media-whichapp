import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RegisterService {
  static const _baseUrl = 'http://192.168.100.252:8080/api/users';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> register(String username, String password, String email, String name) async {
  final url = Uri.parse('$_baseUrl/register');
  
  try {
    final response = await http.post(
      url,
      body: {
        'username': username,
        'password': password,
        'email': email,
        'name': name,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData['register']['status'] == 'success') {
        return {'status': 'success', 'message': 'Đăng ký thành công'};
      } else if (responseData['register']['message'] == 'Username already exists') {
        // Thêm điều kiện kiểm tra nếu username đã tồn tại
        return {'status': 'error', 'message': 'Tên tài khoản đã tồn tại'};
      }
    }
    return {'status': 'error', 'message': 'Lỗi khi đăng ký'};
  } catch (e) {
    return {'status': 'error', 'message': 'Lỗi kết nối: $e'};
  }
}

}

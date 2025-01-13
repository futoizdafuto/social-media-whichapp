import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RegisterService {

   static const _baseUrl = 'https://192.168.100.228:8443/api/users';
  //  static const _baseUrl = 'https://10.150.105.205:8443/api/users';

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
        String email = responseData['register']['email'].toString();
        await _storage.write(key: 'email_register', value: email);
        return {'status': 'success', 'message': 'Gửi mã xác thực thành công'};

      } else if (responseData['register']['message'] == 'Username already exists') {
        // Thêm điều kiện kiểm tra nếu username đã tồn tại
        return {'status': 'error', 'message': 'Tên tài khoản đã tồn tại'};
      } else if (responseData['register']['message'] == 'Email already exists') {
          return {'status': 'error', 'message': 'Email đã tồn tại'};
        }
    }
    return {'status': 'error', 'message': 'Lỗi khi đăng ký'};
  } catch (e) {
    return {'status': 'error', 'message': 'Lỗi kết nối: $e'};
  }
}

  Future<String?> getEmail() async {
    return await _storage.read(key: 'email_register');
  }
}

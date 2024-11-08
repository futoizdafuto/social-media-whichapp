import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class LoginService {
  static const _baseUrl = 'https://192.168.100.252:8443/api/users';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> login(String username, String password) async {
    final url = Uri.parse('$_baseUrl/login');
    try {
      final response = await http.post(
        url,
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['login']['status'] == 'success') {
          String token = responseData['login']['token']['token'];
          String userId = responseData['login']['data']['user']['id'].toString();

          await _storage.write(key: 'token', value: token);
          await _storage.write(key: 'userId', value: userId);
          return {'status': 'success', 'token': token, 'userId': userId};
        }
      }
      return {'status': 'error', 'message': 'Tài khoản hoặc mật khẩu không chính xác!'};
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi kết nối: $e'};
    }
  }

Future<Map<String, dynamic>> reLogin(String token) async {
  final url = Uri.parse('$_baseUrl/reLogin');
  try {
    final response = await http.post(
      url,
      body: {'token': token},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['relogin']['status'] == 'success') {
        String newToken = responseData['relogin']['newToken'];
        await _storage.write(key: 'token', value: newToken); // Cập nhật lại token
        return {'status': 'success', 'newToken': newToken};
      }
    }
    return {'status': 'error', 'message': 'Hết phiên đăng nhập'};
  } catch (e) {
    return {'status': 'error', 'message': 'Lỗi kết nối: $e'};
  }
}


  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
  Future<Map<String, dynamic>> logout() async {
  final url = Uri.parse('$_baseUrl/logout');
  final token = await _storage.read(key: 'token');

  if (token == null) {
    return {'status': 'error', 'message': 'No token found'};
  }

  try {
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // In ra header để kiểm tra
    print("Headers: $headers");

    final response = await http.post(
      url,
      headers: headers,
      body: {
        'token': token,
      },
    );

    final responseData = json.decode(response.body);
    if (response.statusCode == 200 && responseData['logout']['status'] == 'success') {
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'userId');
      return {'status': 'success', 'message': 'Logged out successfully'};
    } else {
      return {
        'status': 'error',
        'message': responseData['logout']['message'] ?? 'Logout failed'
      };
    }
  } catch (e) {
    return {'status': 'error', 'message': 'Lỗi kết nối: $e'};
  }
}

}

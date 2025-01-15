import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Forgotpasswordservices {
   static const _baseUrl = 'https://192.168.1.8:8443/api/users';
  //  static const _baseUrl = 'https://10.150.105.205:8443/api/users';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

 // Gửi yêu cầu quên mật khẩu
 Future<Map<String, dynamic>> sendForgotPasswordRequest(String email) async {
  final url = Uri.parse('$_baseUrl/forgot_password');
  try {
    final response = await http.post(
      url,
      body: {'email': email}, // Gửi theo định dạng x-www-form-urlencoded
    );

    if (response.statusCode == 200) {
 final responseData = jsonDecode(response.body);
        // Lưu email vào storage
        String email = responseData['email'].toString();
        await _storage.write(key: 'email_forgot_password', value: email);

        return responseData; // Trả về response đã chứa email
    } else {
      return {
        'status': 'error',
        'message': 'Email hoặc username không tồn tại',
      };
    }
  } catch (e) {
    return {'status': 'error', 'message': e.toString()};
  }
}

  Future<String?> getEmail() async {
    return await _storage.read(key: 'email_forgot_password');
  }


   // Cập nhật mật khẩu
  Future<Map<String, dynamic>> updatePassword(String newPassword) async {
    final email = await getEmail();
    if (email == null) {
      return {'status': 'error', 'message': 'Email không tồn tại trong bộ nhớ.'};
    }

    final url = Uri.parse('$_baseUrl/update_password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'password': newPassword}, // Gửi email và mật khẩu mới
      );

      if (response.statusCode == 200) {
       final responseData = json.decode(response.body);
      // Kiểm tra nếu trạng thái là 'success' và thay thế thông điệp
      if (responseData['status'] == 'success') {
          // Xóa email trong storage sau khi cập nhật mật khẩu thành công
        await _storage.delete(key: 'email_forgot_password');
        return {
          'status': 'success',
          'message': 'Mật khẩu đã được cập nhật thành công.',  
        };
      }
      return responseData;
      } else {
        final responseData = json.decode(response.body);
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Có lỗi xảy ra khi cập nhật mật khẩu.',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi kết nối: $e'};
    }
  }
}
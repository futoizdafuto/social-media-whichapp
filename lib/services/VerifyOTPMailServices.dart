import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Verifyotpmailservices {
  //  static const _baseUrl = 'https://192.168.1.8:8443/api/users';
  //  static const _baseUrl = 'https://10.150.105.205:8443/api/users';
        static const _baseUrl = 'https://192.168.1.6:8443/api/users';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

 // Hàm xác minh OTP
  Future<Map<String, dynamic>> verifyOtp(String otp) async {
  final email = await _storage.read(key: 'email_register');
  if (email == null) {
    return {'status': 'error', 'message': 'Email không tồn tại trong bộ nhớ.'};
  }

  final url = Uri.parse('$_baseUrl/verify_otp');
  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'otp': otp}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

  // Dịch thông báo thành công
      String successMessage;
      if (responseData['message'] == 'OTP successfully authenticated. User registration successful.') {
        successMessage = 'Xác minh OTP thành công. Đăng ký tài khoản thành công.';
      } else {
        successMessage = responseData['message'] ?? 'Thành công';
      }


      return {
        'status': 'success',
        'message': successMessage,
        'data': responseData['data'],
      };
    } else {
      final responseData = json.decode(response.body);
      
      // Kiểm tra và dịch các thông báo lỗi từ Spring Boot
      if (responseData.containsKey('message')) {
        String errorMessage;
        
        if (responseData['message'] == 'Email does not exist or is invalid.') {
          errorMessage = 'Email không tồn tại hoặc không hợp lệ.';
        } else if (responseData['message'] == 'OTP has expired. Please register again.') {
          errorMessage = 'OTP đã hết hạn. Vui lòng đăng ký lại.';
        } else if (responseData['message'] == 'OTP is not valid.') {
          errorMessage = 'OTP không hợp lệ.';
        } else if (responseData['message'] == 'OTP has expired. Please try again.') {
          errorMessage = 'OTP đã hết hạn. Vui lòng thử lại.';
        } else if (responseData['message'] == 'Username already exists') {
          errorMessage = 'Tên tài khoản đã tồn tại';
        } else {
          errorMessage = 'Xác minh OTP thất bại.';
        }
        
        return {'status': 'error', 'message': errorMessage};
      } else {
        return {'status': 'error', 'message': 'Có lỗi xảy ra trong quá trình xác minh OTP.'};
      }
    }
  } catch (e) {
    return {'status': 'error', 'message': 'Lỗi kết nối: $e'};
  }

  }
  // Xác minh OTP quên mật khẩu
  Future<Map<String, dynamic>> verifyOtpForgotPassword(String otp) async {
    final email = await _storage.read(key: 'email_forgot_password');
    if (email == null) {
      return {'status': 'error', 'message': 'Email không tồn tại trong bộ nhớ.'};
    }

    final url = Uri.parse('$_baseUrl/verify_otp_forgot_password');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'email': email, 'otp': otp},  // Gửi theo định dạng x-www-form-urlencoded
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Dịch thông báo thành công
        String successMessage;
        if (responseData['message'] == 'OTP verified successfully.') {
          successMessage = 'Xác minh OTP thành công.';
        } else {
          successMessage = responseData['message'] ?? 'Thành công';
        }

        return {
          'status': 'success',
          'message': successMessage,
          'data': responseData['data'],
        };
      } else {
        final responseData = json.decode(response.body);
        
        // Kiểm tra và dịch các thông báo lỗi từ Spring Boot
        if (responseData.containsKey('message')) {
          String errorMessage;
          
          if (responseData['message'] == 'Invalid or expired OTP.') {
            errorMessage = 'OTP không hợp lệ hoặc đã hết hạn.';
          } else {
            errorMessage = responseData['message'] ?? 'Xác minh OTP thất bại.';
          }
          
          return {'status': 'error', 'message': errorMessage};
        } else {
          return {'status': 'error', 'message': 'Có lỗi xảy ra trong quá trình xác minh OTP.'};
        }
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Lỗi kết nối: $e'};
    }
  }


}
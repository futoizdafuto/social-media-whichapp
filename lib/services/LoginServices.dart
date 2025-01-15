import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:socially_app_flutter_ui/data/models/notification/notification.dart';

class LoginService {
  static const _baseUrl = 'https://192.168.100.228:8443/api/users';
  // static const _baseUrl = 'https://10.150.105.205:8443/api/users';


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
        String userName = responseData['login']['data']['user']['name'];
        String realuserName = responseData['login']['data']['user']['username'];
        String avatarUrl = responseData['login']['data']['user']['avatar_url'] ?? '';

        // Ghi lại tất cả thông tin vào storage và ghi đè nếu có dữ liệu cũ
        await _storage.write(key: 'token', value: token);
        await _storage.write(key: 'userId', value: userId);
        await _storage.write(key: 'userName', value: userName); // Lưu tên người dùng
        await _storage.write(key: 'avatarUrl', value: avatarUrl); // Lưu avatar người dùng
        await _storage.write(key: 'realuserName', value: realuserName);// username

        return {'status': 'success', 'token': token, 'userId': userId, 'realuserName': realuserName, 'userName': userName, 'avatarUrl': avatarUrl};
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
        // Lưu lại thông tin mới của người dùng
        String userId = responseData['relogin']['data']['user']['id'].toString();
        String userName = responseData['relogin']['data']['user']['name'];
        String realuserName = responseData['relogin']['data']['user']['username'];
        String avatarUrl = responseData['relogin']['data']['user']['avatar_url'] ?? '';

        // Ghi đè dữ liệu mới vào storage
        await _storage.write(key: 'userId', value: userId);
        await _storage.write(key: 'userName', value: userName); // Lưu tên người dùng
        await _storage.write(key: 'avatarUrl', value: avatarUrl); // Lưu avatar người dùng
        await _storage.write(key: 'realuserName', value: realuserName); // username
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
    Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }

  Future<String?> getNameUser() async {
    return await _storage.read(key: 'userName');
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
      // Xóa tất cả dữ liệu của người dùng sau khi logout
      await _storage.delete(key: 'token');
      await _storage.delete(key: 'userId');
      await _storage.delete(key: 'userName');
      await _storage.delete(key: 'avatarUrl');
      await _storage.delete(key: 'realuserName'); // Nếu cần

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

Future<Map<String, dynamic>> loginWithGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
      'openid',
    ],
  );

  try {
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      return {'status': 'error', 'message': 'Người dùng hủy đăng nhập Google'};
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;

    if (accessToken == null) {
      return {'status': 'error', 'message': 'Không lấy được Access Token'};
    }

    // Gửi Access Token đến backend để xác thực
    final backendResponse = await http.get(
      Uri.parse('$_baseUrl/oauth2/google'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (backendResponse.statusCode == 200) {
      final responseBody = json.decode(backendResponse.body);

      if (responseBody['Login'] == true) {
        final token = responseBody['token'];
        await _storage.write(key: 'token', value: token);

          String userId = responseBody['data']['user']['id'].toString();
          String userName = responseBody['data']['user']['name'];
          String realuserName = responseBody['data']['user']['username'];
          String avatarUrl = responseBody['data']['user']['avatar_url'] ?? '';

  
          await _storage.write(key: 'userId', value: userId);
          await _storage.write(key: 'userName', value: userName); // Lưu tên người dùng
          await _storage.write(key: 'avatarUrl', value: avatarUrl); // Lưu avatar người dùng
          await _storage.write(key: 'realuserName', value: realuserName);// username
        return {
          'status': 'success',
          'message': 'Đăng nhập thành công',
          'token': token,
        };
      } else {
        return {
          'status': 'error',
          'message': responseBody['message'] ?? 'Lỗi đăng nhập',
        };
      }
    } else {
      final errorResponse = json.decode(backendResponse.body);
      return {
        'status': 'error',
        'message': errorResponse['message'] ?? 'Lỗi khi gọi API backend',
      };
    }
  } catch (e) {
    return {'status': 'error', 'message': 'Lỗi Google Sign-In: $e'};
  }
}
Future<List<NotificationA>> getAllNotifications() async {
  String? token = await _storage.read(key: 'token');
  String? userId = await _storage.read(key: 'userId');
  final response = await http.get(
    Uri.parse('$_baseUrl/$userId/notifications'),  // Thay thế URL bằng URL của bạn
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) => NotificationA.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
}
}

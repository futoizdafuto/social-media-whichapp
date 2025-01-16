import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:socially_app_flutter_ui/data/models/notification/notification.dart';

class LoginService {
  // static const _baseUrl = 'https://192.168.1.8:8443/api/users';
  // static const _baseUrl = 'https://10.150.105.205:8443/api/users';
  static const _baseUrl = 'https://192.168.1.6:8443/api/users';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
Future<List<dynamic>> getAllUsers() async {
  final url = Uri.parse('$_baseUrl'); // API URL để lấy danh sách user
  final token = await _storage.read(key: 'token'); // Lấy token từ storage

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

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
        int roleUser = responseData['login']['data']['user']['role'];
        String gender = responseData['login']['data']['user']['gender'] ?? ''; // Lấy gender
        String birthday = responseData['login']['data']['user']['birthday'] ?? ''; // Lấy birthday

        // Ghi lại tất cả thông tin vào storage và ghi đè nếu có dữ liệu cũ
        await _storage.write(key: 'token', value: token);
        await _storage.write(key: 'userId', value: userId);
        await _storage.write(key: 'userName', value: userName); // Lưu tên người dùng
        await _storage.write(key: 'avatarUrl', value: avatarUrl); // Lưu avatar người dùng
        await _storage.write(key: 'realuserName', value: realuserName);// username
        await _storage.write(key: 'gender', value: gender); // Lưu gender
        await _storage.write(key: 'birthday', value: birthday); // Lưu birthday
        // await _storage.write(key: 'role', value: roleUser);
        return {'status': 'success', 'token': token, 'userId': userId, 'realuserName': realuserName, 'userName': userName, 'avatarUrl': avatarUrl, 'role': roleUser,   'gender': gender,  // Trả về gender
          'birthday': birthday,};
      }else if (responseData['login']['message'] ==
          'Your account has been banned.') {
        return {
          'status': 'error',
          'message': 'Tài khoản của bạn đã bị cấm.'
        };
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
        int role = responseData['relogin']['data']['user']['role']; // Lấy role
        String gender = responseData['relogin']['data']['user']['gender'] ?? ''; // Lấy gender
        String birthday = responseData['relogin']['data']['user']['birthday'] ?? ''; // Lấy birthday

        // Ghi đè dữ liệu mới vào storage
        await _storage.write(key: 'userId', value: userId);
        await _storage.write(key: 'userName', value: userName); // Lưu tên người dùng
        await _storage.write(key: 'avatarUrl', value: avatarUrl); // Lưu avatar người dùng
        await _storage.write(key: 'realuserName', value: realuserName); // username
        await _storage.write(key: 'gender', value: gender); // Lưu gender
        await _storage.write(key: 'birthday', value: birthday); // Lưu birthday
        return {'status': 'success', 'newToken': newToken, 'role':role};
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
      await _storage.delete(key: 'realuserName'); 
      await _storage.delete(key: 'gender');
      await _storage.delete(key: 'birthday'); 

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
          String gender = responseBody['data']['user']['gender'] ?? ''; // Lấy gender
          String birthday = responseBody['data']['user']['birthday'] ?? ''; // Lấy birthday

  
          await _storage.write(key: 'userId', value: userId);
          await _storage.write(key: 'userName', value: userName); // Lưu tên người dùng
          await _storage.write(key: 'avatarUrl', value: avatarUrl); // Lưu avatar người dùng
          await _storage.write(key: 'realuserName', value: realuserName);// username
          await _storage.write(key: 'gender', value: gender); // Lưu gender
          await _storage.write(key: 'birthday', value: birthday); // Lưu birthday
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

Future<Map<String, dynamic>> updateInformation({
  required int userId,
  String? gender,
  String? birthDate,
  File? avatarFile,
}) async {
  final url = Uri.parse('$_baseUrl/update_information');
  final token = await _storage.read(key: 'token');

  if (token == null) {
    return {'status': 'error', 'message': 'Authentication token not found'};
  }

  try {
    // Build the multipart request
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['userId'] = userId.toString();

    if (gender != null) {
      request.fields['gender'] = gender;
    }

    if (birthDate != null) {
      request.fields['birthDate'] = birthDate;
    }

    if (avatarFile != null) {
      request.files.add(await http.MultipartFile.fromPath('avatarFile', avatarFile.path));
    }

    // Send the request
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['updateInformationUser']['status'] == 'success') {
        return {
          'status': 'success',
          'user': responseData['updateInformationUser']['user'],
        };
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Failed to update information',
        };
      }
    } else {
      return {
        'status': 'error',
        'message': 'Failed to update information. Status code: ${response.statusCode}',
      };
    }
  } catch (e) {
    return {'status': 'error', 'message': 'Connection error: $e'};
  }
}
Future<Map<String, dynamic>> banUser(int userId) async {
  final url = Uri.parse('$_baseUrl/banUser?userId=$userId');
  final token = await _storage.read(key: 'token');

  if (token == null) {
    return {'status': 'error', 'message': 'Authentication token not found'};
  }

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return {
        'status': 'success',
        'message': responseData['message'] ?? 'User has been banned',
      };
    } else {
      final errorResponse = json.decode(response.body);
      return {
        'status': 'error',
        'message': errorResponse['message'] ?? 'Failed to ban user',
      };
    }
  } catch (e) {
    return {'status': 'error', 'message': 'Connection error: $e'};
  }
}
Future<Map<String, dynamic>> unbanUser(int userId) async {
  final url = Uri.parse('$_baseUrl/unbanUser?userId=$userId');
  final token = await _storage.read(key: 'token');

  if (token == null) {
    return {'status': 'error', 'message': 'Authentication token not found'};
  }

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'userId': userId}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return {
        'status': 'success',
        'message': responseData['message'] ?? 'User has been unbanned',
      };
    } else {
      final errorResponse = json.decode(response.body);
      return {
        'status': 'error',
        'message': errorResponse['message'] ?? 'Failed to unban user',
      };
    }
  } catch (e) {
    return {'status': 'error', 'message': 'Connection error: $e'};
  }
}
Future<Map<String, dynamic>> updateProfile({
  required int userId,
  String? name,  // Thêm name
  String? gender,
  String? birthDate,
  File? avatarFile,
}) async {
  final url = Uri.parse('$_baseUrl/update_profile');  // API endpoint của bạn
  final token = await _storage.read(key: 'token');

  if (token == null) {
    return {'status': 'error', 'message': 'Authentication token not found'};
  }

  try {
    // Xây dựng multipart request
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['userId'] = userId.toString();

    // Thêm các trường vào request nếu có
    if (name != null) {
      request.fields['name'] = name;
    }

    if (gender != null) {
      request.fields['gender'] = gender;
    }

    if (birthDate != null) {
      request.fields['birthDate'] = birthDate;
    }

    if (avatarFile != null) {
      request.files.add(await http.MultipartFile.fromPath('avatarFile', avatarFile.path));
    }

    // Gửi request
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['updateInformationUser']['status'] == 'success') {
        return {
          'status': 'success',
          'user': responseData['updateInformationUser']['user'],
        };
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'Failed to update profile',
        };
      }
    } else {
      return {
        'status': 'error',
        'message': 'Failed to update profile. Status code: ${response.statusCode}',
      };
    }
  } catch (e) {
    return {'status': 'error', 'message': 'Connection error: $e'};
  }
}

}

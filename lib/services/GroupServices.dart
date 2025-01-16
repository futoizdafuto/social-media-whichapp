import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:socially_app_flutter_ui/services/LoginServices.dart';

class GroupService {
  // static const _baseUrl = 'https://192.168.1.8:8443/api/users';
  static const _baseUrl = 'https://10.0.172.216:8443/api/groups';

  // static const _baseUrl = 'https://192.168.1.40:8443/api/users';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LoginService _loginService = LoginService(); // Instance of LoginService to use reLogin

  // A helper function to manage token retrieval
  Future<String?> _getValidToken() async {
    final token = await _storage.read(key: 'token');
    return token; // Just return the token from storage if it exists
  }
  Future<Map<String, dynamic>> getGroupsByRole(int userId, String role) async {
    String? token = await _getValidToken();
    if (token == null) {
      return {
        'status': 'error',
        'message': 'Failed to get valid token. Please log in again.',
      };
    }
    String? userIdString = await _storage.read(key: 'userId');

    int userId = int.parse(userIdString!); // Đây chính là kiểu "long" trong Dart

    final url = Uri.parse('$_baseUrl?userId=$userId&role=$role'); // Giả sử endpoint là '/groups'
    try {
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',  // Đảm bảo API nhận dữ liệu dạng JSON
      };

      // Body với userId và role

      final response = await http.get(url, headers: headers);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Giả sử responseData là danh sách các nhóm theo role
        if (responseData != null) {
          List<Map<String, Object>> groups = [];

          for (var groupData in responseData) {
            List<Map<String, Object>> members = [];
            for (var member in groupData['members']) {
              if (member['role'] == role) {
                members.add({
                  'id': member['id'],
                  'userId': member['userId'],
                  'role': member['role'],
                  'joinedAt': member['joinedAt'],
                });
              }
            }

            // Nếu nhóm có thành viên với role tương ứng, thêm vào danh sách
            if (members.isNotEmpty) {
              groups.add({
                'id': groupData['id'],
                'name': groupData['name'],
                'description': groupData['description'],
                'avatar': groupData['avatar'],
                'createdAt': groupData['createdAt'],
                'members': members,
              });
            }
          }

          return {
            'status': 'success',
            'message': 'Successfully fetched groups.',
            'groups': groups,
          };
        } else {
          return {
            'status': 'error',
            'message': 'Failed to fetch group data.',
          };
        }
      } else {
        return {
          'status': 'error',
          'message': 'HTTP error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'An error occurred: $e',
      };
    }
  }
  Future<Map<String, dynamic>> createGroup({
    required String name,
    required String description,
    required String avatar,
    required int adminUserId,
    required List<int> userIds,
  }) async {
    // Lấy token từ FlutterSecureStorage
    String? token = await _getValidToken();
    if (token == null) {
      return {
        'status': 'error',
        'message': 'Failed to get valid token. Please log in again.',
      };
    }

    final url = Uri.parse('$_baseUrl/create');  // Đường dẫn đến API tạo nhóm

    try {
      // Header của yêu cầu
      final headers = {
        'Authorization': 'Bearer $token',


      };

      // Body của yêu cầu
      final body = {
        'name': name,
        'description': description,
        'avatar': avatar,
       'adminUserId': adminUserId.toString(), // Chuyển đổi adminUserId thành chuỗi
  'userIds': userIds.map((id) => id.toString()).toList().join(','), // Chuyển danh sách userIds thành chuỗi
      };

      // Gửi yêu cầu HTTP POST để tạo nhóm
      final response = await http.post(url, headers: headers, body: body);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // Xử lý khi tạo nhóm thành công
        final responseData = json.decode(response.body);
        return {
          'status': 'success',
          'message': responseData['message'],
        };
      } else {
        return {
          'status': 'error',
          'message': 'HTTP error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'An error occurred: $e',
      };
    }
  }



// Method to get follows and update the token
}
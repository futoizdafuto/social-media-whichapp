import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Messageservices {

  //  static const _baseUrl = 'https://192.168.1.8:8443/api/users';
  //  static const _baseUrl = 'https://10.150.105.205:8443/api/users';
        static const _baseUrl = 'https://192.168.1.6:8443/api/chat';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

   Future<Map<String, dynamic>> getGroupMessages(int groupId) async {
    // Lấy token từ FlutterSecureStorage
    String? token = await _getValidToken();
    if (token == null) {
      return {
        'status': 'error',
        'message': 'Failed to get valid token. Please log in again.',
      };
    }

    // URL cho endpoint lấy danh sách tin nhắn của nhóm
    final url = Uri.parse('$_baseUrl/getMessages/group');

    try {
      // Tạo form data với groupId
      final requestBody = {
        'groupId': groupId.toString(),
      };

      // Header của yêu cầu
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

      // Gửi yêu cầu HTTP POST
      final response = await http.post(url, headers: headers, body: requestBody);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // Xử lý khi API trả về thành công
        final responseData = json.decode(response.body);

        if (responseData['getMessagesGroup'] != null &&
            responseData['getMessagesGroup']['status'] == 'success') {
          return {
            'status': 'success',
            'message': 'Successfully fetched group messages.',
            'groupId': responseData['getMessagesGroup']['groupId'],
            'messages': responseData['getMessagesGroup']['data']['messages'],
          };
        } else {
          return {
            'status': 'error',
            'message': responseData['getMessagesGroup']['message'] ?? 'Unknown error',
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

  Future<String?> _getValidToken() async {
    // Lấy token từ FlutterSecureStorage
    try {
      return await _storage.read(key: 'token');
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

}

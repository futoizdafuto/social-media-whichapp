import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class BlockService {
  // static const _baseUrl = 'https://10.0.172.216:8443/api/users';
    //  static const _baseUrl = 'https://192.168.1.8:8443/api/users';
         static const _baseUrl = 'https://192.168.100.228:8443/api/users';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // A helper function to manage token retrieval
  Future<String?> _getValidToken() async {
    final token = await _storage.read(key: 'token');
    return token;
  }

  // Method to get blocked users for the logged-in user
  Future<Map<String, dynamic>> getBlock() async {
    final realUserName = await _storage.read(key: 'realuserName');
    if (realUserName == null) {
      return {
        'status': 'error',
        'message': 'User is not logged in. Please log in first.',
      };
    }

    String? token = await _getValidToken();
    if (token == null) {
      return {
        'status': 'error',
        'message': 'Failed to get valid token. Please log in again.',
      };
    }

    final url = Uri.parse('$_baseUrl/blocks?username=$realUserName');
    try {
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null && responseData['status'] == 'success') {
          List blockedUsers = responseData['blocked_users'] ?? [];
          return {
            'status': 'success',
            'message': responseData['message'],
            'blocked_users': blockedUsers,
          };
        } else {
          return {
            'status': 'error',
            'message': responseData?['message'] ?? 'Failed to fetch blocked users.',
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


  // Method to block a user
  Future<Map<String, dynamic>> blockUser(String targetUsername) async {
    final realUserName = await _storage.read(key: 'realuserName');
    if (realUserName == null) {
      return {
        'status': 'error',
        'message': 'User is not logged in. Please log in first.',
      };
    }

    String? token = await _getValidToken();
    if (token == null) {
      return {
        'status': 'error',
        'message': 'Failed to get valid token. Please log in again.',
      };
    }

    final url = Uri.parse('$_baseUrl/block');
    try {
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final body = {
        'username': realUserName,
        'targetUsername': targetUsername,
        'token': token,
      };

      final response = await http.post(url, headers: headers, body: body);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null && responseData['status'] == 'success') {
          return {
            'status': 'success',
            'message': responseData['message'],
          };
        } else {
          return {
            'status': 'error',
            'message': responseData?['message'] ?? 'Failed to block the user.',
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

  // Method to unblock a user
  Future<Map<String, dynamic>> unblockUser(String targetUsername) async {
    final realUserName = await _storage.read(key: 'realuserName');
    if (realUserName == null) {
      return {
        'status': 'error',
        'message': 'User is not logged in. Please log in first.',
      };
    }

    String? token = await _getValidToken();
    if (token == null) {
      return {
        'status': 'error',
        'message': 'Failed to get valid token. Please log in again.',
      };
    }

    final url = Uri.parse('$_baseUrl/unblock');
    try {
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final body = {
        'username': realUserName,
        'targetUsername': targetUsername,
        'token': token,
      };

      final response = await http.post(url, headers: headers, body: body);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null && responseData['status'] == 'success') {
          return {
            'status': 'success',
            'message': responseData['message'],
          };
        } else {
          return {
            'status': 'error',
            'message': responseData?['message'] ?? 'Failed to unblock the user.',
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
  // Method to get a list of blockers and their blocked users
  Future<Map<String, dynamic>> getListBlock() async {
    final realUserName = await _storage.read(key: 'realuserName');
    if (realUserName == null) {
      return {
        'status': 'error',
        'message': 'User is not logged in. Please log in first.',
      };
    }

    String? token = await _getValidToken();
    if (token == null) {
      return {
        'status': 'error',
        'message': 'Failed to get valid token. Please log in again.',
      };
    }

    final url = Uri.parse('$_baseUrl/blockers');  // Updated URL to fetch blocker data
    try {
      final headers = {
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(url, headers: headers);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData != null && responseData['status'] == 'success') {
          // Safely parse the blocker_and_blocked field
          var blockerAndBlocked = responseData['blocker_and_blocked'];

          // Ensure blocker_and_blocked is a Map<String, dynamic>
          if (blockerAndBlocked is Map<String, dynamic>) {
            // Return the parsed map
            return {
              'status': 'success',
              'blocker_and_blocked': blockerAndBlocked,
              'message': responseData['message'],
            };
          } else {
            return {
              'status': 'error',
              'message': 'Invalid blocker_and_blocked format.',
            };
          }
        } else {
          return {
            'status': 'error',
            'message': responseData?['message'] ?? 'Failed to fetch blocked users.',
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


}

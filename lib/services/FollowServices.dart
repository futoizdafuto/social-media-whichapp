import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:socially_app_flutter_ui/services/LoginServices.dart';

class FollowService {
   static const _baseUrl = 'https://10.0.172.216:8443/api/users';
  // static const _baseUrl = 'https://192.168.1.40:8443/api/users';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LoginService _loginService = LoginService();  // Instance of LoginService to use reLogin

  // A helper function to manage token retrieval
  Future<String?> _getValidToken() async {
    final token = await _storage.read(key: 'token');
    return token;  // Just return the token from storage if it exists
  }

  // Method to get follows and update the token
  Future<Map<String, dynamic>> getFollows() async {
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

    final url = Uri.parse('$_baseUrl/follows?username=$realUserName');
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
          List followingCountList = responseData['following_list'] ?? [];
          List followedCountList = responseData['followed_list'] ?? [];
          int followerCount = responseData['follower_count'] ?? 0;

          // If a new token is returned in the response, update it in FlutterSecureStorage
          String? newToken = responseData['newToken'];
          if (newToken != null) {
            await _storage.write(key: 'token', value: newToken);  // Save new token
          }

          return {
            'status': 'success',
            'message': responseData['message'],
            'following_count': followingCountList.length,
            'followed_count': followedCountList.length,
            'following_list': followingCountList,
            'followed_list': followedCountList,
            'follower_count': followerCount,
          };
        } else {
          return {
            'status': 'error',
            'message': responseData?['message'] ?? 'Failed to fetch follow data.',
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
  Future<Map<String, dynamic>> getFollowUser(String username) async {
    // Không cần lấy realUserName từ storage nữa, mà sử dụng username từ tham số
    if (username.isEmpty) {
      return {
        'status': 'error',
        'message': 'Username is required.',
      };
    }

    String? token = await _getValidToken();
    if (token == null) {
      return {
        'status': 'error',
        'message': 'Failed to get valid token. Please log in again.',
      };
    }

    final url = Uri.parse('$_baseUrl/follows?username=$username');
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
          List followingCountList = responseData['following_list'] ?? [];
          List followedCountList = responseData['followed_list'] ?? [];
          int followerCount = responseData['follower_count'] ?? 0;

          // If a new token is returned in the response, update it in FlutterSecureStorage
          String? newToken = responseData['newToken'];
          if (newToken != null) {
            await _storage.write(key: 'token', value: newToken);  // Save new token
          }

          return {
            'status': 'success',
            'message': responseData['message'],
            'following_count': followingCountList.length,
            'followed_count': followedCountList.length,
            'following_list': followingCountList,
            'followed_list': followedCountList,
            'follower_count': followerCount,
          };
        } else {
          return {
            'status': 'error',
            'message': responseData?['message'] ?? 'Failed to fetch follow data.',
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

  // Method to follow a user
  Future<Map<String, dynamic>> followUser(String targetUsername) async {
    final realUserName = await _storage.read(key: 'realuserName');
    if (realUserName == null) {
      return {
        'status': 'error',
        'message': 'User is not logged in. Please log in first.',
      };
    }

    final token = await _getValidToken();
    if (token == null) {
      return {
        'status': 'error',
        'message': 'Failed to get valid token. Please log in again.',
      };
    }

    final url = Uri.parse('$_baseUrl/follow');
    try {
      final headers = {
        'Authorization': 'Bearer $token',
      };

      // Log the token and headers for debugging
      print("Token: $token");
      print("Request Headers: $headers");

      // Add token to the body
      final body = {
        'username': realUserName,
        'targetUsername': targetUsername,
        'token': token, // Add the token in the body as well
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
            'message': responseData?['message'] ?? 'Failed to follow the user.',
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
  Future<Map<String, dynamic>> unfollowUser(String targetUsername) async {
    final realUserName = await _storage.read(key: 'realuserName');
    if (realUserName == null) {
      return {
        'status': 'error',
        'message': 'User is not logged in. Please log in first.',
      };
    }

    final token = await _getValidToken();
    if (token == null) {
      return {
        'status': 'error',
        'message': 'Failed to get valid token. Please log in again.',
      };
    }

    final url = Uri.parse('$_baseUrl/unfollow');
    try {
      final headers = {
        'Authorization': 'Bearer $token',
      };

      // Log the token and headers for debugging
      print("Token: $token");
      print("Request Headers: $headers");

      // Add token to the body
      final body = {
        'username': realUserName,
        'targetUsername': targetUsername,
        'token': token, // Add the token in the body as well
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
            'message': responseData?['message'] ?? 'Failed to unfollow the user.',
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
   Future<Map<String, dynamic>> getAllUsers() async {
     String? token = await _getValidToken();  // Get valid token
     if (token == null) {
       return {
         'status': 'error',
         'message': 'Failed to get valid token. Please log in again.',
       };
     }

     final url = Uri.parse('$_baseUrl/usernames');  // Endpoint for usernames
     try {
       final headers = {
         'Authorization': 'Bearer $token',  // Include the token in the header
       };

       final response = await http.get(url, headers: headers);  // Make the request

       print("Response status: ${response.statusCode}");
       print("Response body: ${response.body}");

       if (response.statusCode == 200) {
         final responseData = json.decode(response.body);

         // Check if the response contains valid data
         if (responseData != null) {
           // Check if usernames are returned and format the response
           List usernames = responseData; // As the response is an array of strings

           return {
             'status': 'success',
             'message': 'Usernames fetched successfully.',
             'users': usernames,
           };
         } else {
           return {
             'status': 'error',
             'message': 'Failed to fetch usernames.',
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

import 'dart:convert';
import '../user/user.dart';

class Post {
  final int postId;
  final User user;
  final String content;
  final List<Media> mediaList;
  final DateTime createdAt;

  Post({
    required this.postId,
    required this.user,
    required this.content,
    required this.mediaList,
    required this.createdAt,
  });

  // Tạo một đối tượng Post từ JSON
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['post_id'] ?? 0, // Giá trị mặc định nếu không có
      user: json['user'] != null
          ? User.fromJson(json['user'])
          : User.defaultUser(),
      content: json['content'] ?? '', // Giá trị mặc định nếu không có
      mediaList: json['mediaList'] != null
          ? List<Media>.from(
              json['mediaList'].map((media) => Media.fromJson(media)))
          : [], // Trả về danh sách rỗng nếu không có
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(), // Giá trị mặc định là thời điểm hiện tại
    );
  }

  // Chuyển đổi đối tượng Post thành JSON
  Map<String, dynamic> toJson() {
    return {
      'post_id': postId,
      'user': user.toJson(),
      'content': content,
      'mediaList': mediaList.map((media) => media.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Media {
  final int mediaId;
  final String mediaUrl;
  final String type; // Thêm thuộc tính type để xác định ảnh hoặc video

  Media({
    required this.mediaId,
    required this.mediaUrl,
    required this.type, // Yêu cầu khai báo type
  });

  // Phương thức factory để khởi tạo từ JSON
  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      mediaId: json['media_id'] ?? 0,
      mediaUrl: json['url'] ?? '',
      type: json['type'] ?? 'image', // Mặc định là 'image' nếu không có
    );
  }

  // Chuyển đối tượng thành JSON
  Map<String, dynamic> toJson() {
    return {
      'media_id': mediaId,
      'media_url': mediaUrl,
      'type': type,
    };
  }

  // Kiểm tra loại phương tiện là ảnh hay video
  bool get isImage => type == 'image';
  bool get isVideo => type == 'video';
}

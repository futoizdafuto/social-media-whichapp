import 'dart:convert';
import '../user/user.dart';

class Post {
  final int postId;
  final User user;
  final String content;
  final List<Media> mediaList;
  final DateTime createdAt;
  int likeCount;
  int commentCount;

// Phương thức tạo một Post với các giá trị mặc định
  static Post defaultPost() {
    return Post(
      postId: 0, // Giá trị mặc định cho postId
      user: User.defaultUser(), // Sử dụng user mặc định
      content: '', // Chuỗi content mặc định
      mediaList: [], // Danh sách media mặc định là rỗng
      createdAt: DateTime.now(), // Thời gian tạo mặc định là thời điểm hiện tại
      likeCount: 0, // Số lượng like mặc định là 0
      commentCount: 0, // Số lượng like mặc định là 
    );
  }
  Post({
    required this.postId,
    required this.user,
    required this.content,
    required this.mediaList,
    required this.createdAt,
    this.likeCount = 0, // Cung cấp giá trị mặc định nếu null
    this.commentCount = 0, // Cung cấp giá trị mặc định nếu null
  });

  // Tạo một đối tượng Post từ JSON
  factory Post.fromJson(Map<String, dynamic> json) {
  return Post(
    postId: json['post_id'] ?? 0, // Sử dụng giá trị mặc định nếu không có
    user: json['user'] != null ? User.fromJson(json['user']) : User.defaultUser(), // Kiểm tra null và sử dụng defaultUser nếu null
    content: json['content'] ?? '', // Nếu content là null, sử dụng chuỗi rỗng
    mediaList: json['mediaList'] != null
        ? List<Media>.from(json['mediaList'].map((media) => Media.fromJson(media)))
        : [], // Nếu mediaList là null, sử dụng danh sách rỗng
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(), // Nếu createdAt là null, sử dụng thời gian hiện tại
    likeCount: json['like_count'] ?? 0, // Nếu like_count là null, sử dụng 0
    commentCount: json['comment_count'] ?? 0, // Nếu like_count là null, sử dụng 0
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
      'like_count': likeCount,
      'comment_count': commentCount,
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

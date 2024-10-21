// tạo ra model để trao đổi và lưu trữ dữ liệu
class Post {
  final int post_id;
  final int user_id;
  final String content;
  final String img_url;
  final String video_url;
  final DateTime? created_at;

  //constructor
  Post(
      {required this.post_id,
      required this.user_id,
      required this.content,
      required this.img_url,
      required this.video_url,
      required this.created_at});

  // tạo đối tượng từ json ( chuyển dữ liệu từ JSON và chuyển
  // định dạng(JSON) này thành đối tượng dart)
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        post_id: ['post_id'] as int,
        user_id: ['user_id'] as int,
        content: ['content'] as String,
        img_url: ['img_url'] as String,
        video_url: ['video_url'] as String,
        created_at: DateTime.parse(json['created_at'] as String));
  }

  // chuyển đối tượng DARD thành JSON
  Map<String, dynamic> toJson() {
    return {
      'post_id': post_id,
      'user_id': user_id,
      'content': content,
      'img_url': img_url,
      'video_url': video_url,
      'created_at': created_at?.toIso8601String(),
    };
  }
}

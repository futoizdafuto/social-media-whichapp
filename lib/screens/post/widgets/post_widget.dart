import 'package:flutter/material.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';

class PostWidget extends StatelessWidget {
  final String userName;
  final String content;
  final String imageUrl;
  final String videoUrl;

  const PostWidget({
    Key? key,
    required this.userName,
    required this.content,
    this.imageUrl = '',
    this.videoUrl = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với tên người dùng và thời gian
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: k2MainThemeColor,
                  child: Text(
                    userName[0], // Chữ cái đầu làm avatar
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Nội dung bài đăng
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),

            // Hiển thị ảnh nếu có
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(imageUrl),
              ),
            const SizedBox(height: 10),

            // Hiển thị video nếu có
            if (videoUrl.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 200,
                width: double.infinity,
                child: const Center(child: Icon(Icons.videocam, size: 50)),
              ),

            // Các nút like, bình luận, chia sẻ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up),
                  label: const Text('Thích'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.comment),
                  label: const Text('Bình luận'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                  label: const Text('Chia sẻ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

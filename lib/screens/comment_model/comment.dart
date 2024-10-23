import 'package:flutter/material.dart';

class CommentModal {
  // Hàm hiển thị modal
  static Future<void> show(BuildContext context) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép modal chiếm toàn màn hình nếu cần
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Phần 1: Row hiển thị số lượt like
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "42 Likes",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Icon(Icons.favorite, color: Colors.red),
                ],
              ),
              const SizedBox(height: 16),

              // Phần 2: Khung chứa các comment
              Expanded(
                child: ListView(
                  children: const [
                    CommentItem(
                      avatarUrl: "https://via.placeholder.com/48",
                      userName: "John Doe",
                      commentText: "Great post!",
                      timestamp: "5 mins ago",
                    ),
                    CommentItem(
                      avatarUrl: "https://via.placeholder.com/48",
                      userName: "Alice",
                      commentText: "Amazing!",
                      timestamp: "10 mins ago",
                    ),
                    // Thêm các comment khác...
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Phần 3: Row chứa ô nhập và nút gửi
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Nhập bình luận...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      // Xử lý gửi comment
                      print("Comment sent!");
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Widget hiển thị một comment
class CommentItem extends StatelessWidget {
  final String avatarUrl;
  final String userName;
  final String commentText;
  final String timestamp;

  const CommentItem({
    Key? key,
    required this.avatarUrl,
    required this.userName,
    required this.commentText,
    required this.timestamp,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8.0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
            radius: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(commentText),
                const SizedBox(height: 4),
                Text(
                  timestamp,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/comment_model/comment_items.dart';

class CommentModal {
  static Future<void> show(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            margin: const EdgeInsets.only(top: 35),
            // color: Colors.grey,
            padding: EdgeInsets.only(
              top: 20,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // phần hiển thị lượt reaction
                Container(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.favorite, color: kHeartRed),
                      SizedBox(width: 8),
                      Text(
                        "42.699 Likes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // phần hiển thị cấc comment
                Expanded(
                    child: ListView(
                  children: const [
                    CommentItems(
                      avatar_url: "https://via.placeholder.com/48",
                      user_name: "John Doe",
                      comment_content: "Great post!",
                      timestamp: "5 mins ago",
                    ),
                    CommentItems(
                      avatar_url: "https://via.placeholder.com/48",
                      user_name: "John Doe",
                      comment_content: "Great post!",
                      timestamp: "5 mins ago",
                    ),
                    CommentItems(
                      avatar_url: "https://via.placeholder.com/48",
                      user_name: "John Doe",
                      comment_content: "Great post!",
                      timestamp: "5 mins ago",
                    ),
                    CommentItems(
                      avatar_url: "https://via.placeholder.com/48",
                      user_name: "John Doe",
                      comment_content: "Great post!",
                      timestamp: "5 mins ago",
                    ),
                    CommentItems(
                      avatar_url: "https://via.placeholder.com/48",
                      user_name: "John Doe",
                      comment_content: "Great post!",
                      timestamp: "5 mins ago",
                    ),
                    CommentItems(
                      avatar_url: "https://via.placeholder.com/48",
                      user_name: "John Doe",
                      comment_content: "Great post!",
                      timestamp: "5 mins ago",
                    ),
                    CommentItems(
                      avatar_url: "https://via.placeholder.com/48",
                      user_name: "John Doe",
                      comment_content: "Great post!",
                      timestamp: "5 mins ago",
                    ),
                  ],
                )),
                // phần nhập comment
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        maxLines: 5,
                        minLines: 1,
                        decoration: InputDecoration(
                            hintText: "Viết bình luận",
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30))),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.send,
                          color: Colors.blue,
                        ))
                  ],
                ),
                const SizedBox(height: 20)
              ],
            ),
          );
        });
  }
}

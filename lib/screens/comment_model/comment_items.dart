import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CommentItems extends StatelessWidget {
  const CommentItems(
      {super.key,
      required this.avatar_url,
      required this.user_name,
      required this.comment_content,
      required this.timestamp});
  final String avatar_url;
  final String user_name;
  final String comment_content;
  final String timestamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(avatar_url),
              radius: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user_name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(comment_content),
                const SizedBox(height: 4),
                Text(
                  timestamp,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ))
          ],
        ));
  }
}

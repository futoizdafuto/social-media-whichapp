import 'package:flutter/material.dart';
import 'package:socially_app_flutter_ui/data/models/post/comment.dart';
import 'package:socially_app_flutter_ui/data/models/post/post.dart';
import 'package:socially_app_flutter_ui/screens/comment_model/comment_items.dart';
import '../../data/repository/post_repository.dart';

class CommentModal {
  static final PostRepository postRepository = PostRepository();

  static Future<void> show(BuildContext context, Post post, VoidCallback updateCommentCount) async {
    final TextEditingController commentController = TextEditingController();
    List<Comment> comments = [];
    bool isLoaded = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> loadComments() async {
              if (!isLoaded) {
                try {
                  comments = await postRepository.getCommentsByPost(post.postId);
                  setState(() {
                    isLoaded = true;
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to load comments: $e')),
                  );
                }
              }
            }

            loadComments();

            return Container(
              padding: EdgeInsets.only(
                top: 20,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: isLoaded
                        ? ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return CommentItems(
                                avatar_url: comment.user.avatar_url,
                                user_name: comment.user.name,
                                comment_content: comment.content,
                                timestamp: comment.createdAt.toString(),
                              );
                            },
                          )
                        : const Center(child: CircularProgressIndicator()),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: commentController,
                          maxLines: 5,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: "Viết bình luận",
                            contentPadding: const EdgeInsets.all(15),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () async {
                          String commentContent = commentController.text.trim();
                          if (commentContent.isNotEmpty) {
                            try {
                              await postRepository.addComment(post.postId, commentContent);
                              commentController.clear();

                              // Gọi callback để cập nhật commentCount
                              updateCommentCount();

                              // Tải lại danh sách bình luận
                              setState(() {
                                isLoaded = false;
                              });
                              await loadComments();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to add comment: $e')),
                              );
                            }
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

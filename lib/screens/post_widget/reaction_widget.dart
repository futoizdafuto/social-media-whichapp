import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/data/models/post/post.dart';
import '../../data/repository/post_repository.dart';

class PostStat extends StatefulWidget {
  final String iconPath;
  final String activeIconPath; // Đường dẫn cho icon khi active
  int value; // Bỏ final để giá trị có thể thay đổi
  final int userId;
  final int postId;
  final Post post;
  final VoidCallback? onTap;
  final bool isLikeButton; // Đánh dấu đây là nút like
  final bool isActive;

  PostStat({
    Key? key,
    required this.iconPath,
    required this.activeIconPath,
    required this.value,
    required this.userId,
    required this.postId,
    required this.post,
    this.onTap,
    required this.isLikeButton,
    this.isActive = false,
  }) : super(key: key);

  @override
  _PostStatState createState() => _PostStatState();
}

class _PostStatState extends State<PostStat> {
  late bool _isActive; // Trạng thái hiện tại của nút like
  final PostRepository postRepository = PostRepository();

  @override
  void initState() {
    super.initState();
    _isActive = widget.isActive; // Gán giá trị ban đầu từ widget
    // Gọi API để lấy trạng thái like
    if (widget.isLikeButton) {
      print('Fetching initial like status...');
      _fetchLikeStatus(); // Gọi API nếu đây là nút like
    }
  }

  Future<void> _fetchLikeStatus() async {
    try {
      bool isLiked = await postRepository.getLikeStatus(widget.postId);
      setState(() {
        _isActive = isLiked; // Cập nhật trạng thái
        print('trạng thái like');
        print(_isActive);   
      });
    } catch (e) {
      print('Error fetching like status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (widget.isLikeButton) {
          setState(() {
            _isActive = !_isActive;
          });

          try {
            // Gọi API
            Map<String, dynamic> response = _isActive
                ? await postRepository.likePost(widget.postId)
                : await postRepository.unlikePost(widget.postId);

            // Kiểm tra nếu phản hồi chứa like_count
            if (response.containsKey('like_count')) {
              setState(() {
                // Cập nhật số lượng like trong danh sách posts
                //final postIndex = posts.indexWhere((p) => p.postId == widget.postId);
                  widget.post.likeCount = response['like_count'];
                  widget.value = response['like_count'];
                
              });
            }
             // Hiển thị thông báo nếu có
            if (response.containsKey('message')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(response['message'])),
              );
            }
          } catch (error) {
            // Hiển thị lỗi và khôi phục trạng thái
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Something went wrong: $error')),
            );

            // Khôi phục trạng thái nếu lỗi
            setState(() {
              _isActive = !_isActive;
            });
          }
        }

        if (widget.onTap != null) {
          widget.onTap!();
        }
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          children: [
            SvgPicture.asset(
              _isActive
                  ? widget.activeIconPath
                  : widget.iconPath, // Đổi icon dựa trên trạng thái
              color: _isActive ? kHeartRed : kBlack,
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 8.0),
            Text(
              widget.value.toString(), // Hiển thị số lượng like đã cập nhật
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: kBlack,
                    fontSize: 18,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

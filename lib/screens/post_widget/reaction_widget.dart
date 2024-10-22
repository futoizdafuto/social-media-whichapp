import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';

class PostStat extends StatefulWidget {
  final String iconPath;
  final String activeIconPath; // Đường dẫn cho icon khi active
  final String value;
  final VoidCallback? onTap;
  final bool isLikeButton; // Đánh dấu đây là nút like
  final bool isActive;

  const PostStat({
    Key? key,
    required this.iconPath,
    required this.activeIconPath, // Thêm active icon
    required this.value,
    this.onTap,
    required this.isLikeButton,
    this.isActive = false,
  }) : super(key: key);

  @override
  _PostStatState createState() => _PostStatState();
}

class _PostStatState extends State<PostStat> {
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _isActive = widget.isActive; // Khởi tạo trạng thái
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.isLikeButton) {
          setState(() {
            _isActive = !_isActive; // Chuyển đổi trạng thái khi nhấn
          });
        }
        if (widget.onTap != null) {
          widget.onTap!(); // Gọi hàm onTap nếu có
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
              widget.value,
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

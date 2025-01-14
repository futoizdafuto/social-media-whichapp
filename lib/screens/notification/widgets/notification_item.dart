import 'package:flutter/material.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/widgets/profile_image.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    Key? key,
    //required this.name,
    required this.notification,
    required this.isRead,
  }) : super(key: key);

  //final String name;
  final String notification;
  final bool isRead; // Trạng thái đọc

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: () => Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => MessageDetailScreen(),
      //   ),
      // ),
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
        margin: const EdgeInsets.only(bottom: 10.0),
        decoration: BoxDecoration(
          color: kWhite.withOpacity(0.6), // Nền của toàn bộ thông báo
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thanh trạng thái
            Container(
              width: 8.0, // Chiều ngang bằng 1/5 chiều cao
              height: 40.0, // Chiều cao bằng với avatar cũ
              decoration: BoxDecoration(
                color: isRead
                    ? Colors.grey.withOpacity(0.6) // Màu xám nếu đã đọc
                    : Colors.blue.withOpacity(0.8), // Màu xanh dương nếu chưa đọc
                borderRadius: BorderRadius.circular(5.0), // Bo góc nhẹ
              ),
            ),
            const SizedBox(width: 16.0), // Khoảng cách giữa thanh và nội dung
            // Nội dung thông báo
            Expanded(
              child: Text(
                notification,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: kBlack, // Màu chữ
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

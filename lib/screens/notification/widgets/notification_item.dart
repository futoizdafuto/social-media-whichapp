import 'package:flutter/material.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/widgets/profile_image.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    Key? key,
    required this.name,
    required this.notification,
  }) : super(key: key);

  final String name;
  final String notification;

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
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: kWhite.withOpacity(0.60),
          borderRadius: BorderRadius.circular(32.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileImage(radius: 35.0),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(color: kBlack),
                  ),
                  Text(
                    notification,
                    style: Theme.of(context).textTheme.labelSmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

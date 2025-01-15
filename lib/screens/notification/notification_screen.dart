import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/notification/widgets/notification_background.dart';
import 'package:socially_app_flutter_ui/screens/notification/widgets/notification_item.dart';
import 'package:socially_app_flutter_ui/data/models/notification/notification.dart';
import 'package:socially_app_flutter_ui/screens/nav/nav.dart';
import 'package:socially_app_flutter_ui/services/LoginServices.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late Future<List<NotificationA>> _notifications;
  //static final LoginService loginService = LoginService();

  @override
  void initState() {
    super.initState();
    _notifications = LoginService().getAllNotifications(); // Sử dụng userId thực tế
  }

  @override
  Widget build(BuildContext context) {
    return NotificationBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: SvgPicture.asset('assets/icons/button_back.svg'),
          ),
        ),
        body: FutureBuilder<List<NotificationA>>(
          future: _notifications,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No notifications found'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final notification = snapshot.data![index];
                  return NotificationItem(
                    //name: 'Notification', // Tùy chỉnh nếu cần
                    notification: notification.message,
                    isRead: notification.isRead,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

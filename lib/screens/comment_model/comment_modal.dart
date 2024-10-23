import 'package:flutter/material.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';

class CommentModal {
  static Future<void> show(BuildContext context) async {
    return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        builder: (context) {
          return Container(
            margin: ,
            child: const Column(
              children: [
                // phần hiển thị lượt reaction
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "42k Likes",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.favorite, color: kHeartRed)
                  ],
                ),
                // phần hiển thị cấc comment
                // phần nhập comment
              ],
            ),
          );
        });
  }
}

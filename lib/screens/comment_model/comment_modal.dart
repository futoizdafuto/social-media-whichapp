import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';

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
              // color: Colors.grey,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            ),
            margin: const EdgeInsets.only(top: 35),
            // color: Colors.grey,
            padding: const EdgeInsets.only(
              top: 20,
              left: 16,
              right: 16,
            ),
            child: Column(
              children: [
                // phần hiển thị lượt reaction
                Container(
                  // decoration: const BoxDecoration(
                  //     border: Border(
                  //         bottom: BorderSide(
                  //   color: Colors.grey,
                  //   width: 1.0,
                  // ))),
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
                // phần hiển thị cấc comment\

                Expanded(
                    child: ListView(
                  children: const [
                    
                  ],
                )),
                // phần nhập comment
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                            hintText: "Viết bình luận",
                            contentPadding: const EdgeInsets.only(left: 25),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30))),
                      ),
                    ),
                    const SizedBox(width: 8),
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

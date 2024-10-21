import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';

import '../settings_modal/setting_item.dart';

class PostElement extends StatefulWidget {
  const PostElement({super.key});

  @override
  State<PostElement> createState() => _PostElementState();
}

class _PostElementState extends State<PostElement> {
  // Hàm xử lý sự kiện khi chọn Setting
  static void _handleSetting(BuildContext context, String message) {
    Navigator.pop(context); // Đóng modal
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 32.0,
          ),
          padding: const EdgeInsets.all(14.0),
          height: size.height * 0.40,
          width: size.width,
          decoration: BoxDecoration(
            // color: Colors.red,
            borderRadius: BorderRadius.circular(20.0),
            image: DecorationImage(
              image: AssetImage('assets/images/building-${index + 1}.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage:
                            AssetImage('assets/images/profile_image.jpg'),
                        maxRadius: 16.0,
                      ),
                      const SizedBox(width: 8.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dennis Reynolds',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: kWhite),
                          ),
                          Text(
                            '2 hrs ago',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .copyWith(color: const Color(0xFFD8D8D8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // ----------------------------------------------------------------------//
                  //xử lý setting bài viết ở đây
                  IconButton(
                    onPressed: () {
                      // Gọi modal với các tham số tùy chỉnh
                      SettingsModal.show(
                        context,
                        items: [
                          SettingItem(
                            icon: Icons.edit,
                            title: 'Sửa bài viết',
                            onTap: () =>
                                _handleSetting(context, 'Setting 1 selected'),
                          ),
                          SettingItem(
                            icon: Icons.delete,
                            title: 'Xóa bài viết',
                            onTap: () =>
                                _handleSetting(context, 'Setting 2 selected'),
                          ),
                        ],
                      );
                    },
                    icon: const Icon(Icons.more_vert, color: kWhite),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPostStat(
                    context: context,
                    iconPath: 'assets/icons/favorite_border.svg',
                    value: '5.2K',
                  ),
                  _buildPostStat(
                    context: context,
                    iconPath: 'assets/icons/favorite_border.svg',
                    value: '1.1K',
                  ),
                  _buildPostStat(
                    context: context,
                    iconPath: 'assets/icons/favorite_border.svg',
                    value: '5.2K',
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Container _buildPostStat({
    required BuildContext context,
    required String iconPath,
    required String value,
  }) {
    // nút like
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E5).withOpacity(0.40),
        borderRadius: BorderRadius.circular(35.0),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            color: kWhite,
          ),
          const SizedBox(width: 8.0),
          Text(
            value,
            style:
                Theme.of(context).textTheme.labelSmall!.copyWith(color: kWhite),
          ),
        ],
      ),
    );
  }
}

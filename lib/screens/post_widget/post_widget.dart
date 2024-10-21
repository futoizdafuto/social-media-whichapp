import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/model/mock_post.dart';
import '../settings_modal/setting_item.dart';

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
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
      itemCount: mockPosts.length,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        final post = mockPosts[index];
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 30,
                bottom: 10,
                left: 0.5,
                right: 0.5,
              ),
              padding: const EdgeInsets.all(14.0),
              height: size.height * 0.40,
              width: size.width,
              decoration: BoxDecoration(
                // color: Colors.red,
                borderRadius: BorderRadius.circular(3),

                image: DecorationImage(
                  image: AssetImage(post.img_url), // khúc này sử dụng mock nè
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
                                onTap: () => _handleSetting(
                                    context, 'Setting 1 selected'),
                              ),
                              SettingItem(
                                icon: Icons.delete,
                                title: 'Xóa bài viết',
                                onTap: () => _handleSetting(
                                    context, 'Setting 2 selected'),
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
                        iconPath: 'assets/icons/comments.svg',
                        value: '1.1K',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                alignment: Alignment.centerLeft,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                ), // Căn chỉnh nội dung Container sang trái
                child: Container(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: const Text(
                    "Lorem ipsum dolor sit amet, consectetur adipisicing elit. Cupiditate iure fuga atque maxime aperiam distinctio quis at voluptate? Odit saepe iure tempore dolores earum omnis!",
                    textAlign: TextAlign.justify,
                  ),
                ))
          ],
        );
      },
    );
  }

  // Border _boderContent(){}

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
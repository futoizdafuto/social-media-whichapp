import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/home/widgets/background.dart';
import 'package:socially_app_flutter_ui/screens/notification/notification_screen.dart';
import '../settings_modal/setting_item.dart';



class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  
 // Hàm xử lý sự kiện khi chọn Setting
  static void _handleSetting(BuildContext context, String message) {
    Navigator.pop(context); // Đóng modal
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // firstly, we need to create a backround
    return Background(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Socially',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                onPressed: () {
                   // Thêm Navigator.push để chuyển trang
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationScreen()),
                  );
                },
                icon: SvgPicture.asset('assets/icons/notif.svg'),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Feed',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 30.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      height: 56.0,
                      width: 56.0,
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 24.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: k3GradientAccent,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 12.0,
                            offset: const Offset(0, 4),
                            color: k3Pink.withOpacity(0.52),
                          ),
                        ],
                      ),
                      child: SvgPicture.asset('assets/icons/only_plus.svg'),
                    ),
                    ...List.generate(
                      5,
                      (index) => Container(
                        height: 56.0,
                        width: 56.0,
                        margin: EdgeInsets.only(
                          left: 30.0,
                          right: index == 4 ? 30.0 : 0.0,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 2.0, color: k2AccentStroke),
                          image: const DecorationImage(
                            image:
                                AssetImage('assets/images/profile_image.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
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
                        image: AssetImage(
                            'assets/images/building-${index + 1}.jpg'),
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
                                  backgroundImage: AssetImage(
                                      'assets/images/profile_image.jpg'),
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
                                          .copyWith(
                                              color: const Color(0xFFD8D8D8)),
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
                                      icon: Icons.settings,
                                      title: 'Setting 1',
                                      onTap: () => _handleSetting(
                                          context, 'Setting 1 selected'),
                                    ),
                                    SettingItem(
                                      icon: Icons.settings_applications,
                                      title: 'Setting 2',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildPostStat({
    required BuildContext context,
    required String iconPath,
    required String value,
  }) {
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

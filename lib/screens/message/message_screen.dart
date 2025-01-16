import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/data/models/group.dart';
import 'package:socially_app_flutter_ui/screens/message/widgets/message_background.dart';
import 'package:socially_app_flutter_ui/screens/nav/nav.dart';
import 'package:socially_app_flutter_ui/screens/message/widgets/message_item.dart';
import 'package:socially_app_flutter_ui/services/GroupServices.dart';

import 'SettingChatScreen.dart'; // Import màn hình SettingChatScreen

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key? key}) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  late Future<List<Group>?> _groupsFuture;
  final GroupService _groupService = GroupService();
  @override
  void initState() {
    super.initState();
    _groupsFuture = _groupService.getUserGroups(); // Gọi API để lấy danh sách nhóm
  }

  @override
  Widget build(BuildContext context) {
    return MessageBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Nav()),
            ),
            icon: SvgPicture.asset('assets/icons/button_back.svg'),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: SvgPicture.asset('assets/icons/menu.svg'),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const SettingChatScreen(),
                  );
                },
              ),
            ),
          ],
        ),
        body: FutureBuilder<List<Group>?>(
          future: _groupsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No groups found.'));
            }

            final groups = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Messages',
                      style: Theme.of(context)
                          .textTheme
                          .displaySmall!
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 30.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            blurRadius: 25.0,
                            color: kBlack.withOpacity(0.10),
                          )
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: kWhite,
                          isDense: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            borderSide: const BorderSide(
                              width: 0.0,
                              style: BorderStyle.none,
                            ),
                          ),
                          prefixIcon: Image.asset('assets/images/search.png'),
                          hintText: 'Search for contacts',
                          hintStyle: Theme.of(context)
                              .textTheme
                              .labelSmall!
                              .copyWith(color: k1LightGray),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return MessageItem(
                          name: group.name,
                          message: group.description ?? 'No description',
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


class GroupAvatar extends StatelessWidget {
  final String mainImage;
  final List<String> subImages;

  const GroupAvatar({
    Key? key,
    required this.mainImage,
    required this.subImages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          // Hình lớn
          ClipOval(
            child: Image.asset(
              mainImage,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          // Hình nhỏ bên trong
          if (subImages.isNotEmpty)
            Positioned(
              top: 5,
              left: 5,
              child: ClipOval(
                child: Image.asset(
                  subImages[0],
                  width: 25,
                  height: 25,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (subImages.length > 1)
            Positioned(
              top: 5,
              right: 5,
              child: ClipOval(
                child: Image.asset(
                  subImages[1],
                  width: 25,
                  height: 25,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (subImages.length > 2)
            Positioned(
              bottom: 5,
              left: 5,
              child: ClipOval(
                child: Image.asset(
                  subImages[2],
                  width: 25,
                  height: 25,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/data/models/group.dart';
import 'package:socially_app_flutter_ui/screens/message/widgets/message_background.dart';
import 'package:socially_app_flutter_ui/screens/nav/nav.dart';
import 'package:socially_app_flutter_ui/screens/message/widgets/message_item.dart';
import 'package:socially_app_flutter_ui/services/GroupServices.dart';
import 'package:socially_app_flutter_ui/data/models/user/user.dart';
import 'package:socially_app_flutter_ui/screens/message/SettingChatScreen.dart';
import 'package:socially_app_flutter_ui/screens/message_detail/message_detail_screen.dart';

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
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                          leading: CircleAvatar(
                            backgroundImage: group.avatar != null
                                ? NetworkImage(group.avatar!) // Nếu nhóm có ảnh, sử dụng ảnh từ URL
                                : null,
                            child: group.avatar == null
                                ? Text(group.name[0]) // Nếu không có ảnh, hiển thị chữ cái đầu tiên
                                : null,
                          ),
                          title: Text(group.name),
                          subtitle: Text(group.description ?? 'No description'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) async {
                              if (value == 'delete') {
                                bool confirm = await _showDeleteDialog(context);
                                if (confirm) {
                                  // Gọi API xóa nhóm
                                  final response = await _groupService.deleteGroup(group.roomId);
                                  if (response['status'] == 'success') {
                                    setState(() {
                                      groups.removeAt(index); // Cập nhật danh sách nhóm sau khi xóa
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(response['message'])),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: ${response['message']}')),
                                    );
                                  }
                                }
                              } else if (value == 'members') {
                                // Gọi API để lấy thành viên và hiển thị trong bottom sheet
                                final members = await _groupService.getMembers(group.roomId);
                                _showMembersBottomSheet(context, members);
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: const [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 10),
                                    Text('Xóa nhóm'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'members',
                                child: Row(
                                  children: const [
                                    Icon(Icons.group, color: Colors.blue),
                                    SizedBox(width: 10),
                                    Text('Xem thành viên'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessageDetailScreen(), // Truyền dữ liệu nhóm vào
                              ),
                            );
                          },
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

  // Hàm để hiển thị danh sách thành viên trong Bottom Sheet
  void _showMembersBottomSheet(BuildContext context, List<User> members) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Members',
                // style: Theme.of(context).textTheme.headline6!.copyWith(
                //   fontWeight: FontWeight.bold,
                // ),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return ListTile(
                    leading: CircleAvatar(
                    radius: 25, // Đặt kích thước của avatar (25px)
                    backgroundImage: member.avatar_url != null
                        ? NetworkImage(member.avatar_url!) // Hiển thị ảnh avatar nếu có
                        : null,
                    child: member.avatar_url == null
                        ? Text(
                            member.name[0], // Hiển thị chữ cái đầu tiên nếu không có avatar
                            style: const TextStyle(fontSize: 20),
                          )
                        : null,
                  ),
                    title: Text(member.name),
                    subtitle: Text(member.email),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

Future<bool> _showDeleteDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('xóa Group'),
        content: const Text('Bạn có chắc muốn xóa Group?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Trả về `false` nếu hủy
            child: const Text('hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Trả về `true` nếu xác nhận
            child: const Text('xóa'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false); // Nếu `null`, mặc định trả về `false`.
}

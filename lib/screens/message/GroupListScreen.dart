// Import necessary packages
import 'package:flutter/material.dart';
import '../../services/GroupServices.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({Key? key}) : super(key: key);

  @override
  _GroupListScreenState createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  List<Map<String, dynamic>> adminGroups = [];
  List<Map<String, dynamic>> memberGroups = [];
  bool isLoading = true;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late GroupService groupService;

  @override
  void initState() {
    super.initState();
    _loadGroups();
    groupService = GroupService();
  }

  // Gọi phương thức getGroupsByRole và phân loại theo role
  Future<void> _loadGroups() async {
    final userIdString = await _storage.read(key: 'userId');
    final userId = int.parse(userIdString!);

    try {
      //final groupService = GroupService();  // Giả sử bạn đã có GroupService
      final adminResponse = await groupService.getGroupsByRole(userId, 'admin');
      final memberResponse = await groupService.getGroupsByRole(userId, 'member');

      setState(() {
        adminGroups = adminResponse['status'] == 'success' ? adminResponse['groups'] : [];
        memberGroups = memberResponse['status'] == 'success' ? memberResponse['groups'] : [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error loading groups: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groups'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Hiển thị loading khi đang tải
          : ListView(
        children: [
          if (adminGroups.isNotEmpty)
            _buildGroupSection('ADMIN', adminGroups),
          if (memberGroups.isNotEmpty)
            _buildGroupSection('MEMBER', memberGroups),
        ],
      ),
    );
  }

  // Tạo phần hiển thị nhóm theo vai trò
  Widget _buildGroupSection(String role, List<Map<String, dynamic>> groups) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            role,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true, // Để không bị tràn nội dung
          physics: const NeverScrollableScrollPhysics(), // Không cho cuộn trong phần này
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return ListTile(
              leading: CircleAvatar(
                radius: 25,  // Thiết lập kích thước của avatar
                backgroundImage: group['avatar'] != null
                    ? NetworkImage(group['avatar']) // Nếu có URL ảnh, hiển thị ảnh từ URL
                    : null,
                child: group['avatar'] == null
                    ? Text(group['name'][0])  // Nếu không có avatar, hiển thị chữ cái đầu
                    : null,
              ),
              title: Text(group['name']),
              subtitle: Text(group['description']),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  // Xác nhận trước khi xóa
                  bool confirm = await _showDeleteDialog(context);
                  if (confirm) {
                    final userIdString = await _storage.read(key: 'userId');
                    //final userId = int.parse(userIdString!);


                    final response = await groupService.deleteGroup(group['id']);
                    if (response['status'] == 'success') {
                      // Thông báo thành công và reload danh sách nhóm
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
                      _loadGroups(); // Tải lại nhóm sau khi xóa
                    } else {
                      // Thông báo lỗi
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response['message']}')));
                    }
                  }
                },
              ),
              onTap: () {
                print('Tapped on group: ${group['name']}');
              },
            );
          },
        ),
      ],
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

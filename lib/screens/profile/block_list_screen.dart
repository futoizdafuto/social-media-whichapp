import 'package:flutter/material.dart';
import '../../services/BlockServices.dart'; // Import BlockService

class BlockedListScreen extends StatefulWidget {
  final List<String> blockedUsers;
  final Function(List<String>) onUpdateBlockedUsers;

  const BlockedListScreen({
    Key? key,
    required this.blockedUsers,
    required this.onUpdateBlockedUsers,
  }) : super(key: key);

  @override
  _BlockedListScreenState createState() => _BlockedListScreenState();
}

class _BlockedListScreenState extends State<BlockedListScreen> {
  final BlockService _blockService = BlockService(); // Ensure you have the API service class

  // Method to confirm unblock and remove the user from the blocked list
  Future<void> _confirmUnblock(BuildContext context, String userId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận bỏ chặn'),
          content: const Text('Bạn có chắc chắn muốn bỏ chặn tài khoản này không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                // Call unblockUser API method
                final response = await _blockService.unblockUser(userId);

                if (response['status'] == 'success') {
                  // Successfully unblocked, remove user from the list
                  setState(() {
                    widget.blockedUsers.remove(userId);
                  });
                  widget.onUpdateBlockedUsers(widget.blockedUsers); // Notify parent widget
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã bỏ chặn tài khoản $userId')),
                  );
                } else {
                  // Handle any errors
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message'])),
                  );
                }

                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Đồng ý'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách chặn'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.blockedUsers.isEmpty
            ? Center(child: Text('Không có người dùng nào bị chặn.'))
            : ListView.builder(
          itemCount: widget.blockedUsers.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(widget.blockedUsers[index]),
              leading: Icon(Icons.block),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle),
                onPressed: () {
                  // Call method to confirm unblock when pressed
                  _confirmUnblock(context, widget.blockedUsers[index]);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

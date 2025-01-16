import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socially_app_flutter_ui/services/FollowServices.dart'; // Import FollowService
import 'package:socially_app_flutter_ui/services/LoginServices.dart';
import '../../services/GroupServices.dart'; // Import GroupService

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FollowService _followService = FollowService();
  final GroupService _groupService = GroupService();
  final LoginService _loginService = LoginService();

  List<String> followingList = []; // List of usernames
  List<String> selectedUsers = []; // Selected users for group
  bool _isLoading = true;
  String _searchText = '';
  String _groupName = '';
  String _groupDescription = '';
  String _groupAvatar = '';

  @override
  void initState() {
    super.initState();
    _loadFollowingList();
  }

  // Load following list from the API
  Future<void> _loadFollowingList() async {
    final followResponse = await _followService.getFollows();
    if (followResponse['status'] == 'success') {
      setState(() {
        followingList = List<String>.from(followResponse['following_list']); // List of usernames
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Failed to load following list');
    }
  }

  // Filter users based on search text
  List<String> _filterUsers() {
    return followingList.where((username) {
      return username.toLowerCase().contains(_searchText.toLowerCase());
    }).toList();
  }

  // Handle selection of users
  void _onUserSelected(String username, bool selected) {
    setState(() {
      if (selected) {
        selectedUsers.add(username); // Add user to selected list
      } else {
        selectedUsers.remove(username); // Remove user from selected list
      }
    });
  }

  Future<int> _getAdminUserId() async {
    try {
      // Lấy userId trực tiếp từ storage
      final userIdString = await _storage.read(key: 'userId');  // Retrieve userId from storage

      if (userIdString == null) {
        throw Exception('No userId found in storage');
      }

      // Convert the userId to an integer (assuming userId is stored as a string)
      final userId = int.tryParse(userIdString);

      if (userId == null) {
        throw Exception('Invalid userId format in storage');
      }

      // Return the admin user ID
      print('Admin user ID: $userId');
      return userId;

    } catch (e) {
      print('Error fetching admin user ID: $e');
      return 0; // Return 0 if error occurs
    }
  }


  Future<List<int>> _getUserIds() async {
    try {
      // Gọi API lấy danh sách tất cả người dùng
      final allUsers = await _loginService.getAllUsers();

      // Lấy danh sách userId của các username được tick chọn
      final selectedUserIds = allUsers
          .where((user) => selectedUsers.contains(user['username']))
          .map<int>((user) {
        var userId = user['userId'];
        if (userId is int) {
          return userId;
        } else {
          print('Error: Invalid userId type');
          return 0; // Return 0 if the type is unexpected
        }
      })
          .toList();

      // Print the selected user IDs
      print('Selected user IDs: $selectedUserIds');

      // Return the user IDs as List<int>
      return selectedUserIds;
    } catch (e) {
      print('Error fetching user IDs: $e');
      return [];
    }
  }
  Future<void> _createGroup() async {
    if (_groupName.isEmpty || selectedUsers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a group name and select at least two users.')),
      );
      return;
    }

    // Get the list of userIds
    final userIds = await _getUserIds();

    if (userIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user IDs')),
      );
      return;
    }

    // Get the admin userId
    final adminUserId = await _getAdminUserId();

    if (adminUserId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get admin user ID')),
      );
      return;
    }

    // Create the group via the GroupService
    try {
      final response = await _groupService.createGroup(
        name: _groupName.toString(),
        description: _groupDescription.toString(),
        avatar: _groupAvatar.toString(),
        adminUserId: adminUserId.toInt(),  // Pass adminUserId
        userIds: userIds,  // Pass userIds as a list of int
      );

      if (response['status'] == 'success') {
        // Show success dialog or navigate back
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Group created successfully!')));
      } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Group created successfully!')));

        // Show error message
        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create group: ${response['message']}')));
      }
    } catch (e) {
      print('Error creating group: $e'); // Log error to the terminal
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Failed to create group: $e')),
      // );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Group'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Name TextField
            TextField(
              onChanged: (value) {
                setState(() {
                  _groupName = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Group Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Group Description TextField
            TextField(
              onChanged: (value) {
                setState(() {
                  _groupDescription = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Group Description (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Group Avatar TextField
            TextField(
              onChanged: (value) {
                setState(() {
                  _groupAvatar = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Group Avatar (Optional - URL)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Search Bar
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Followers',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 16.0),

            // Display loading indicator while fetching data
            _isLoading
                ? const Center(child: CircularProgressIndicator()) // Show loading spinner
                : Expanded(
              child: ListView(
                children: _filterUsers().map((username) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Placeholder image
                    ),
                    title: Text(username),
                    subtitle: Text('No description available'), // Placeholder for description
                    trailing: Checkbox(
                      value: selectedUsers.contains(username),
                      onChanged: (selected) {
                        _onUserSelected(username, selected!);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Show Create Group button if at least 2 users are selected
            if (selectedUsers.length >= 2)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: _createGroup,
                  child: const Text('Create Group'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

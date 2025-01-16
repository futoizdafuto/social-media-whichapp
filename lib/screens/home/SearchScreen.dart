import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socially_app_flutter_ui/services/FollowServices.dart';
import '../profile/profilefollow_screen.dart';  // Import ProfileFollowScreen

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _storage = FlutterSecureStorage();
  List<String> _usernames = [];
  List<String> _filteredUsernames = [];
  bool _isLoading = true;
  String _searchText = '';
  List<String> _followingList = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  // Fetch users and filter out the logged-in user
  Future<void> _loadUsers() async {
    final followService = FollowService();
    String? realUserName = await _storage.read(key: 'realuserName');

    final followResponse = await followService.getFollows();
    if (followResponse['status'] == 'success') {
      setState(() {
        _followingList = List<String>.from(followResponse['following_list']);
      });
    }

    final response = await followService.getAllUsers();

    if (response['status'] == 'success') {
      List<String> allUsers = List<String>.from(response['users']);
      setState(() {
        _usernames = allUsers.where((username) => username != realUserName).toList();
        _filteredUsernames = _usernames; // Initially show all users
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Failed to load users: ${response['message']}');
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchText = value;
      _filteredUsernames = _usernames
          .where((username) => username.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Users"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search for users...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: _filteredUsernames.length,
                itemBuilder: (context, index) {
                  bool isFollowing = _followingList.contains(_filteredUsernames[index]);

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileFollowScreen(
                          username: _filteredUsernames[index],  // Pass the selected username
                          followingList: _followingList,  // Pass the following list
                          followedList: [],  // You can pass the followed list as needed
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(_filteredUsernames[index]),
                      subtitle: Text(isFollowing ? 'Đang theo dõi' : ''),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

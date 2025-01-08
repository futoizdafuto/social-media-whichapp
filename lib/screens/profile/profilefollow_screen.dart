import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/profile/widgets/profile_background.dart';
import 'dart:math' as math;
import 'package:socially_app_flutter_ui/screens/profile/widgets/stat.dart';
import '../../services/FollowServices.dart';
import '../settings_modal/setting_item.dart';
import 'followeruser_list_screen.dart';
import 'setting_profile/setting_profile_screen.dart';
import 'follower_list_screen.dart';

class ProfileFollowScreen extends StatefulWidget {
  final String username;  // Thêm tham số username
  final List<String> followingList;  // Thêm tham số followingList
  final List<String> followedList;   // Thêm tham số followedList

  const ProfileFollowScreen({
    Key? key,
    required this.username,
    required this.followingList,
    required this.followedList,
  }) : super(key: key);

  @override
  _ProfileFollowScreenState createState() => _ProfileFollowScreenState();
}

class _ProfileFollowScreenState extends State<ProfileFollowScreen> {
  String _selectedTab = 'photos';
  late Future<String?> _userNameFuture;

  // Thêm các biến để lưu trữ số lượng followers và following
  int _followingCount = 0;
  int _followedCount = 0;

  // Handle setting modal action
  static void _handleSetting(BuildContext context, String message) {
    Navigator.pop(context); // Close the modal
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Change the active tab
  _changeTab(String tab) {
    setState(() {
      _selectedTab = tab;
    });
  }

  // Hàm lấy dữ liệu follow
  void fetchFollowData() async {
    final followService = FollowService();

    // Lấy thông tin follow cho người dùng theo username được truyền vào
    final followData = await followService.getFollowUser(widget.username);

    if (followData['status'] == 'success') {
      setState(() {
        _followingCount = followData['following_count'];
        _followedCount = followData['followed_count'];
      });
    } else {
      print('Error: ${followData['message']}');
    }
  }

  Future<List<Follower>> _fetchSuggestedUsers(List<String> originalFollowingList) async {
    final followService = FollowService();
    final Set<String> uniqueSuggestedUsers = {}; // Use Set to avoid duplicates
    final List<Follower> suggestedUsers = [];

    // Fetch the real username to avoid showing it in suggested users
    final realUserName = widget.username;

    // Add original following list and logged-in user to the exclusion set
    final exclusionSet = Set<String>.from(originalFollowingList);
    if (realUserName != null) {
      exclusionSet.add(realUserName); // Add the logged-in user to the exclusion set
    }

    for (String username in originalFollowingList) {
      final followData = await followService.getFollowUser(username);

      if (followData['status'] == 'success') {
        List<String> nestedFollowingList = List<String>.from(followData['following_list'] ?? []);
        for (String nestedUser in nestedFollowingList) {
          // Only add users who are not in the original following list and are not the logged-in user
          // and are not already in the suggested users list
          if (!exclusionSet.contains(nestedUser) && !uniqueSuggestedUsers.contains(nestedUser)) {
            uniqueSuggestedUsers.add(nestedUser); // Add to exclusion to prevent duplication
            suggestedUsers.add(
              Follower(
                name: nestedUser,
                subtitle: "",
                profileImageUrl: "https://via.placeholder.com/150",
                isFollowing: false,
              ),
            );
          }
        }
      } else {
        print('Error fetching suggested users for @$username: ${followData['message']}');
      }
    }

    return suggestedUsers;
  }

  @override
  void initState() {
    super.initState();

    // Directly use the username passed to this screen
    _userNameFuture = Future.value(widget.username);  // Assign username directly

    fetchFollowData();  // Gọi hàm lấy dữ liệu follow khi khởi tạo
  }


  @override
  Widget build(BuildContext context) {
    return ProfileBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: SvgPicture.asset('assets/icons/menu.svg'),
                onPressed: () {
                  // Show modal with half-screen content directly
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const SettingProfileScreen(),
                  );
                },
              ),
            ),
          ],
        ),
        body: FutureBuilder<String?>(
          future: _userNameFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            String? username = snapshot.data;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Image and Username
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: math.pi / 4,
                        child: Container(
                          width: 140.0,
                          height: 140.0,
                          decoration: BoxDecoration(
                            border: Border.all(width: 1.0, color: kBlack),
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                        ),
                      ),
                      ClipPath(
                        clipper: ProfileImageClipper(),
                        child: Image.asset(
                          'assets/images/profile_image.jpg',
                          width: 180.0,
                          height: 180.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    username ?? 'Username',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '@$username',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 80.0),

                  // Statistics Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stat(title: 'Posts', value: 35),
                        GestureDetector(
                          onTap: () async {
                            final followService = FollowService();
                            final followData = await followService.getFollowUser(widget.username);


                            if (followData['status'] == 'success') {
                              List<Follower> followedList = List<String>.from(followData['followed_list']).map((username) {
                                return Follower(
                                  name: username,
                                  subtitle: "Đang theo dõi bạn",
                                  profileImageUrl: "https://via.placeholder.com/150",
                                  isFollowing: false,  // This flag does not affect the follow button
                                );
                              }).toList();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowUserListScreen(
                                    title: 'Followers',
                                    followers: followedList,
                                    suggestedUsers: [], // You can keep suggested users empty for now
                                    showFollowButton: false, followingList: [],  // Pass this flag as false
                                  ),
                                ),
                              );
                            } else {
                              print('Error fetching followed data: ${followData['message']}');
                            }
                          },
                          child: Stat(title: 'Followers', value: _followedCount),
                        ),
                        GestureDetector(
                          onTap: () async {
                            // Lấy tên người dùng hiện tại từ 'realUserName'
                            final realUserName = widget.username;

                            final followService = FollowService();
                            final followData = await followService.getFollowUser(realUserName);

                            // Print the entire response to see its structure
                            print('Response from API: $followData');

                            if (followData['status'] == 'success') {
                              List<String> originalFollowingList = List<String>.from(followData['following_list']);

                              // Lấy danh sách gợi ý từ following_list
                              List<Follower> suggestedUsers = await _fetchSuggestedUsers(originalFollowingList);

                              // Tạo danh sách người dùng đã theo dõi
                              List<Follower> followingUsers = originalFollowingList.map((username) {
                                return Follower(
                                  name: username,
                                  subtitle: "",
                                  profileImageUrl: "https://via.placeholder.com/150", // Placeholder image URL
                                  isFollowing: true,
                                );
                              }).toList();

                              // Chuyển đến màn hình 'FollowUserListScreen' để hiển thị danh sách theo dõi
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowUserListScreen(
                                    title: 'Following',
                                    followers: followingUsers,   // Truyền danh sách followers đã được tạo
                                    suggestedUsers: suggestedUsers, // Truyền danh sách suggestedUsers
                                    showFollowButton: true, followingList: [], // Cờ để hiển thị nút theo dõi
                                  ),
                                ),
                              );
                            } else {
                              // If there's an error or status is not 'success'
                              print('Error fetching following data: ${followData['message']}');
                            }
                          },
                          child: Stat(title: 'Following', value: _followingCount), // Stat widget hiển thị số lượng người theo dõi
                        ),


                      ],
                    ),
                  ),
                  const SizedBox(height: 50.0),

                  // Grid of Posts
                  Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: StaggeredGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14.0,
                      crossAxisSpacing: 14.0,
                      children: [
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(19.0),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/Rectangle-5.png',
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: () {
                                      // Gọi modal với các tham số tùy chỉnh
                                      SettingsModal.show(
                                        context,
                                        items: [
                                          SettingItem(
                                            icon: Icons.edit,
                                            title: 'Sửa bài viết',
                                            onTap: () => _handleSetting(context, 'Sửa bài viết được chọn'),
                                          ),
                                          SettingItem(
                                            icon: Icons.delete,
                                            title: 'Xóa bài viết',
                                            onTap: () => _handleSetting(context, 'Xóa bài viết được chọn'),
                                          ),
                                        ],
                                      );
                                    },
                                    icon: const Icon(Icons.more_vert, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(19.0),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/Rectangle-7.png',
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: () {
                                      // Gọi modal với các tham số tùy chỉnh
                                      SettingsModal.show(
                                        context,
                                        items: [
                                          SettingItem(
                                            icon: Icons.edit,
                                            title: 'Sửa bài viết',
                                            onTap: () => _handleSetting(context, 'Sửa bài viết được chọn'),
                                          ),
                                          SettingItem(
                                            icon: Icons.delete,
                                            title: 'Xóa bài viết',
                                            onTap: () => _handleSetting(context, 'Xóa bài viết được chọn'),
                                          ),
                                        ],
                                      );
                                    },
                                    icon: const Icon(Icons.more_vert, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(19.0),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/Rectangle-8.png',
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: () {
                                      // Gọi modal với các tham số tùy chỉnh
                                      SettingsModal.show(
                                        context,
                                        items: [
                                          SettingItem(
                                            icon: Icons.edit,
                                            title: 'Sửa bài viết',
                                            onTap: () => _handleSetting(context, 'Sửa bài viết được chọn'),
                                          ),
                                          SettingItem(
                                            icon: Icons.delete,
                                            title: 'Xóa bài viết',
                                            onTap: () => _handleSetting(context, 'Xóa bài viết được chọn'),
                                          ),
                                        ],
                                      );
                                    },
                                    icon: const Icon(Icons.more_vert, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(19.0),
                            child: Stack(
                              children: [
                                Image.asset(
                                  'assets/images/Rectangle-1.png',
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    onPressed: () {
                                      // Gọi modal với các tham số tùy chỉnh
                                      SettingsModal.show(
                                        context,
                                        items: [
                                          SettingItem(
                                            icon: Icons.edit,
                                            title: 'Sửa bài viết',
                                            onTap: () => _handleSetting(context, 'Sửa bài viết được chọn'),
                                          ),
                                          SettingItem(
                                            icon: Icons.delete,
                                            title: 'Xóa bài viết',
                                            onTap: () => _handleSetting(context, 'Xóa bài viết được chọn'),
                                          ),
                                        ],
                                      );
                                    },
                                    icon: const Icon(Icons.more_vert, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ProfileImageClipper extends CustomClipper<Path> {
  double radius = 35;

  @override
  Path getClip(Size size) {
    Path path = Path()
      ..moveTo(size.width / 2 - radius, radius)
      ..quadraticBezierTo(size.width / 2, 0, size.width / 2 + radius, radius)
      ..lineTo(size.width - radius, size.height / 2 - radius)
      ..quadraticBezierTo(size.width, size.height / 2, size.width - radius,
          size.height / 2 + radius)
      ..lineTo(size.width / 2 + radius, size.height - radius)
      ..quadraticBezierTo(size.width / 2, size.height, size.width / 2 - radius,
          size.height - radius)
      ..lineTo(radius, size.height / 2 + radius)
      ..quadraticBezierTo(0, size.height / 2, radius, size.height / 2 - radius)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

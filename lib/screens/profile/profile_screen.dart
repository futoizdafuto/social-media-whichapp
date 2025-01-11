import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/profile/widgets/profile_background.dart';
import 'dart:math' as math;
import 'package:socially_app_flutter_ui/screens/profile/widgets/stat.dart';
import '../../services/BlockServices.dart';
import '../../services/FollowServices.dart';
import '../settings_modal/setting_item.dart';
import 'setting_profile/setting_profile_screen.dart';
import 'follower_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required String username}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

    // Fetch realUserName from secure storage
    final realUserName = await _getRealUserName();

    if (realUserName == null) {
      print("Error: User is not logged in.");
      return;
    }

    final followData = await followService.getFollows();
    if (followData['status'] == 'success') {
      setState(() {
        _followingCount = followData['following_count'];
        _followedCount = followData['followed_count'];
      });
    } else {
      print('Error: ${followData['message']}');
    }
  }

  // Function to fetch the real username from secure storage
  Future<String?> _getRealUserName() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'realuserName');  // Assuming realUserName is saved under this key
  }
  Future<List<Follower>> fetchWaitingUsers(String realUserName) async {
    final followService = FollowService();
    final List<Follower> waitingUsers = [];
    // Lấy dữ liệu danh sách người dùng đang chờ từ API
    final waitingUsersResponse = await followService.getWaitingUsers(realUserName);
    if (waitingUsersResponse['status'] == 'success') {
      // Lấy danh sách các tên người dùng đang chờ
      List<String> waitingUsernames = List<String>.from(waitingUsersResponse['waiting_users'] ?? []);
      // Duyệt qua danh sách người dùng đang chờ và thêm đối tượng Follower vào danh sách waitingUsers
      for (String username in waitingUsernames) {
        waitingUsers.add(
          Follower(
            name: username,
            subtitle: "Đang chờ bạn chấp nhận",
            profileImageUrl: "https://via.placeholder.com/150", // Thêm ảnh đại diện placeholder
            isFollowing: false, // Điều này có thể thay đổi tùy vào trạng thái follow

          ),
        );
      }

      return waitingUsers;
    } else {
      print('Error fetching waiting users: ${waitingUsersResponse['message']}');
      return [];
    }
  }
  Future<List<Follower>> _fetchSuggestedUsers(List<String> originalFollowingList) async {
    final followService = FollowService();
    final Set<String> uniqueSuggestedUsers = {}; // Use Set to avoid duplicates
    final List<Follower> suggestedUsers = [];

    // Fetch the real username to avoid showing it in suggested users
    final realUserName = await _getRealUserName();

    if (realUserName == null) {
      return []; // Return an empty list if real username is not available
    }

    // Add original following list and logged-in user to the exclusion set
    final exclusionSet = Set<String>.from(originalFollowingList);
    exclusionSet.add(realUserName); // Add the logged-in user to the exclusion set

    // Fetch blocked users of the real username
    final blockService = BlockService();  // Assuming you have a BlockService
    final blockData = await blockService.getBlock();
    if (blockData['status'] == 'success') {
      Map<String, List<String>> blockerAndBlocked = {};
      var blockerAndBlockedData = blockData['blocker_and_blocked'];

      if (blockerAndBlockedData is Map<String, dynamic>) {
        // Safely cast the blocker_and_blocked data to Map<String, List<String>>
        blockerAndBlockedData.forEach((blocker, blockedList) {
          if (blockedList is List<dynamic>) {
            blockerAndBlocked[blocker] = List<String>.from(blockedList);
          }
        });

        // Add all users that the realUserName has blocked to the exclusion set
        blockerAndBlocked.forEach((blocker, blockedList) {
          if (blocker == realUserName) {
            exclusionSet.addAll(blockedList);  // Add the users blocked by realUserName
          }
        });
      }
    } else {
      print('Error fetching blocked users: ${blockData['message']}');
    }

    // Fetch the list of users who have blocked the real username
    final blockListData = await blockService.getListBlock();
    if (blockListData['status'] == 'success') {
      Map<String, List<String>> blockerAndBlocked = {};
      var blockerAndBlockedData = blockListData['blocker_and_blocked'];

      if (blockerAndBlockedData is Map<String, dynamic>) {
        blockerAndBlockedData.forEach((blocker, blockedList) {
          if (blockedList is List<dynamic>) {
            blockerAndBlocked[blocker] = List<String>.from(blockedList);
          }
        });

        // Add all users that have blocked the realUserName to the exclusion set
        blockerAndBlocked.forEach((blocker, blockedList) {
          if (blockedList.contains(realUserName)) {
            exclusionSet.add(blocker);  // Add the users who have blocked the realUserName
          }
        });
      }
    } else {
      print('Error fetching list of blockers: ${blockListData['message']}');
    }

    // Fetch all users from the getAllUser endpoint (list of all usernames)
    final userService = followService;  // Assuming you have a UserService to fetch all users
    final allUsersData = await userService.getAllUsers();

    if (allUsersData['status'] == 'success') {
      List<String> allUsernames = List<String>.from(allUsersData['users'] ?? []);

      // Loop through all users and add them to suggested users if they are not in the exclusion set
      for (String username in allUsernames) {
        // Only add users who are not in the exclusion set (following, blocked, or logged-in user)
        if (!exclusionSet.contains(username) && !uniqueSuggestedUsers.contains(username)) {
          uniqueSuggestedUsers.add(username); // Add to exclusion to prevent duplication

          // Add the user to the suggested list
          suggestedUsers.add(
            Follower(
              name: username,
              subtitle: "",
              profileImageUrl: "https://via.placeholder.com/150",
              isFollowing: false,
            ),
          );
        }
      }
    } else {
      print('Error fetching all users: ${allUsersData['message']}');
    }
    final waitingUsers = await fetchWaitingUsers(realUserName);
    // Debug print: Show waiting users
    print('Waiting users: ${waitingUsers.map((user) => user.name).toList()}');
    // Remove the users who are in the waiting users list from the suggested users list
    suggestedUsers.removeWhere((suggestedUser) {
      return waitingUsers.any((waitingUser) => waitingUser.name == suggestedUser.name);
    });
    // Debug print: Show the final list of suggested users
    print('Suggested users after removing waiting users: ${suggestedUsers.map((user) => user.name).toList()}');
    return suggestedUsers;
  }





  @override
  void initState() {
    super.initState();
    _userNameFuture = FlutterSecureStorage().read(key: 'userName');
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
                        // In your GestureDetector for Followers
                        GestureDetector(
                          onTap: () async {
                            final followService = FollowService();
                            final followData = await followService.getFollows();

                            if (followData['status'] == 'success') {
                              // Explicitly cast the lists to List<String> to avoid type errors
                              List<String> originalFollowedList = List<String>.from(followData['followed_list']);
                              List<Follower> suggestedUsers = await _fetchSuggestedUsers(originalFollowedList);
                             // Fetch realUserName
                              String? realUserName = await _getRealUserName();

                               // Check if realUserName is not null before fetching waiting users
                               if (realUserName != null) {
                               List<Follower> waitingUsers = await fetchWaitingUsers(realUserName);

                              // Navigate to the FollowerListScreen, passing followed users and suggested users
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => FollowerListScreen(
                                     title: 'Followers',
                                     followers: originalFollowedList.map((username) {
                                       return Follower(
                                         name: username,
                                         subtitle: "Đang theo dõi bạn",
                                         profileImageUrl: "https://via.placeholder.com/150",
                                         isFollowing: false,
                                       );
                                     }).toList(),
                                     suggestedUsers: suggestedUsers,  // Pass the suggested users
                                     waitingUsers: waitingUsers,  // Pass the waiting users list
                                     showFollowButton: true,
                                     followingList: List<String>.from(followData['following_list']), // Ensure this is cast too
                                   ),
                                 ),
                               );
                               } else {
                                 print('Error: realUserName is null');
                               }
                            } else {
                              print('Error fetching followed data: ${followData['message']}');
                            }
                          },
                          child: Stat(title: 'Followers', value: _followedCount),
                        ),

// In your GestureDetector for Following
                        GestureDetector(
                          onTap: () async {
                            final followService = FollowService();
                            final followData = await followService.getFollows();

                            if (followData['status'] == 'success') {
                              List<String> originalFollowingList = List<String>.from(followData['following_list']);

                              // Fetch suggested users based on the exclusion logic (following, blocked, real user)
                              List<Follower> suggestedUsers = await _fetchSuggestedUsers(originalFollowingList);

                              List<Follower> followingUsers = originalFollowingList.map((username) {
                                return Follower(
                                  name: username,
                                  subtitle: "Đang theo dõi",
                                  profileImageUrl: "https://via.placeholder.com/150",
                                  isFollowing: true,
                                );
                              }).toList();

                              // Navigate to the FollowerListScreen, passing both following and suggested users
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowerListScreen(
                                    title: 'Following',
                                    followers: followingUsers,
                                    suggestedUsers: suggestedUsers,  // Pass the suggested users
                                    showFollowButton: true,
                                    followingList: originalFollowingList, waitingUsers: [], // Ensure this is cast too
                                  ),
                                ),
                              );
                            } else {
                              print('Error fetching following data: ${followData['message']}');
                            }
                          },
                          child: Stat(title: 'Following', value: _followingCount),
                        )



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

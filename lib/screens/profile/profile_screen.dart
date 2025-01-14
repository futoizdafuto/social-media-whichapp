import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/profile/PostInProfileScreen.dart';
import 'package:socially_app_flutter_ui/screens/profile/widgets/profile_background.dart';
import 'dart:math' as math;
import 'package:socially_app_flutter_ui/screens/profile/widgets/stat.dart';
import '../../services/BlockServices.dart';
import '../../services/FollowServices.dart';
import '../settings_modal/setting_item.dart';
import 'setting_profile/setting_profile_screen.dart';
import '../../data/repository/post_repository.dart';
import 'follower_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required String username}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedTab = 'photos';
  late Future<String?> _userNameFuture;
  late List<dynamic> _posts = []; // Initialize the _posts variable
  late List<dynamic>_imageList = [];


  // Thêm các biến để lưu trữ số lượng followers và following
  int _followingCount = 0;
  int _followedCount = 0;
  int _postsCount = 0;

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
  Future<void> fetchPostCount() async {
    final postService = PostRepository();
    final realUserName = await _getRealUserName(); // Lấy tên người dùng thực tế

    if (realUserName != null) {
      try {
        // Gọi hàm getCountPostByUsername để lấy số lượng bài viết của người dùng
        final postsResponse = await postService.getCountPostByUsername();

        // Kiểm tra phản hồi từ API
        if (postsResponse['status'] == 'success') {
          // Lấy giá trị post_count từ phản hồi
          int postCount = postsResponse['post_count'] ?? 0;

          // Cập nhật số lượng bài viết trong state
          setState(() {
            _postsCount = postCount;  // Lưu số lượng bài viết vào biến _postsCount
          });

          print('Posts count: $_postsCount');
        } else {
          print('Error fetching posts: ${postsResponse['message']}');
        }
      } catch (e) {
        print('Error fetching posts: $e');
      }
    } else {
      print('Error: realUserName is null');
    }
  }

  // Function to fetch the real username from secure storage
  Future<String?> _getRealUserName() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'realuserName');  // Assuming realUserName is saved under this key
  }
  Future<void> fetchImages() async {
    final postService = PostRepository(); // Repository to handle API calls
    final realUserName = await _getRealUserName(); // Fetch the real username from storage

    if (realUserName != null) {
      try {
        final imagesResponse = await postService
            .getImagesByUsername(); // Giả sử bạn đã tạo hàm getImagesByUsername
        if (imagesResponse['status'] == 'success') {
          setState(() {
            _imageList =
            List<Map<String, dynamic>>.from(imagesResponse['image_list']);
          });
          print('Images fetched successfully');
        } else {
          print('Error fetching images: ${imagesResponse['message']}');
        }
      } catch (e) {
        print('Error fetching images: $e');
      }
    }
  }
  Future<void> fetchPosts() async {
    final postService = PostRepository(); // Repository to handle API calls
    final realUserName = await _getRealUserName(); // Fetch the real username from storage

    if (realUserName != null) {
      try {
        // Call the API to fetch posts by username
        final postsResponse = await postService.getPostsByUsername();

        // Check the response status from the API
        if (postsResponse['status'] == 'success') {
          // Extract the list of posts and sort them by creation time (newest first)
          List<dynamic> posts = postsResponse['posts'] ?? [];

          // Sort posts by 'created_at' (descending order)
          posts.sort((a, b) =>
              DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at'])));

          // Update the state with the fetched posts, extract image URLs
          setState(() {
            _posts = posts.map((post) {
              // Extract the list of image URLs for each post
              List<String> imageUrls = [];
              final mediaList = post['mediaList'] ?? [];

              for (var media in mediaList) {
                if (media['type'] == 'image' && media['url'] != null) {
                  imageUrls.add(media['url']); // Add image URLs to the list
                }
              }

              return {
                'post_id': post['post_id'],
                'content': post['content'],
                'created_at': post['created_at'],
                'user': post['user'],
                'image_urls': imageUrls, // Store the image URLs
              };
            }).toList(); // Map posts to include the image URLs
          });

          print('Posts fetched successfully: ${_posts.length} posts');
        } else {
          print('Error fetching posts: ${postsResponse['message']}');
        }
      } catch (e) {
        print('Error fetching posts: $e');
      }
    } else {
      print('Error: realUserName is null');
    }
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
            subtitle: "",
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
  Future<List<Follower>> fetchWaitingUsed() async {
    final followService = FollowService();
    final List<Follower> waitingUsers = [];
    // Lấy dữ liệu danh sách người dùng đang chờ từ API
    final waitingUsersResponse = await followService.getWaitingUsed();
    if (waitingUsersResponse['status'] == 'success') {
      // Lấy danh sách các tên người dùng đang chờ
      List<String> waitingUsernames = List<String>.from(waitingUsersResponse['waiting_usered'] ?? []);
      // Duyệt qua danh sách người dùng đang chờ và thêm đối tượng Follower vào danh sách waitingUsers
      for (String username in waitingUsernames) {
        waitingUsers.add(
          Follower(
            name: username,
            subtitle: "",
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
    final waitingUsed = await fetchWaitingUsed();
    // Debug print: Show waiting users
    print('Waiting users: ${waitingUsers.map((user) => user.name).toList()}');
    // Remove the users who are in the waiting users list from the suggested users list
    suggestedUsers.removeWhere((suggestedUser) {
      return waitingUsers.any((waitingUser) => waitingUser.name == suggestedUser.name);
    });
    suggestedUsers.removeWhere((suggestedUser) {
      return waitingUsed.any((waitingUsered) => waitingUsered.name == suggestedUser.name);
    });
    // Debug print: Show the final list of suggested users
    print('Suggested users after removing waiting users: ${suggestedUsers.map((user) => user.name).toList()}');
    return suggestedUsers;
  }
  void _navigateToPostDetail(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Postinprofilescreen(postImage: imageUrl),
      ),
    );
  }





  @override
  void initState() {
    super.initState();
    _userNameFuture = FlutterSecureStorage().read(key: 'userName');
    fetchFollowData();  // Gọi hàm lấy dữ liệu follow khi khởi tạo
    fetchPostCount();
    fetchImages();
  }
  void _showImageModal(BuildContext context, String imageUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: MediaQuery
                      .of(context)
                      .size
                      .width * 0.6,
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Add edit functionality here
                    },
                    icon: Icon(Icons.edit),
                    label: Text('Sửa bài viết'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      // Add delete functionality here
                    },
                    icon: Icon(Icons.delete),
                    label: Text('Xóa bài viết'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
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
                        Stat(title: 'Posts', value: _postsCount),
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

                                List<Follower> waitingused = await fetchWaitingUsed();
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
                                      followingList: List<String>.from(followData['following_list']), waitingUsered: waitingused, // Ensure this is cast too
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
                              String? realUserName = await _getRealUserName();
                              List<Follower> waitingused = await fetchWaitingUsed();
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
                                    followingList: originalFollowingList, waitingUsered: waitingused, waitingUsers: [], // Ensure this is cast too
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
                      crossAxisCount: 2,  // Số cột trong grid
                      mainAxisSpacing: 14.0,
                      crossAxisSpacing: 14.0,
                      children: List.generate(_imageList.length, (index) {
                        final image = _imageList[index]; // Lấy từng ảnh từ danh sách ảnh
                        final imageUrl = image['image_url'] ?? '';  // Lấy URL ảnh

                        return StaggeredGridTile.count(
                          crossAxisCellCount: 1,
                          mainAxisCellCount: 1.5,
                            child: GestureDetector(
                              onTap: () => _navigateToPostDetail(context, imageUrl),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(19.0),
                            child: Stack(
                              children: [
                                // Hiển thị ảnh nếu URL hợp lệ
                                imageUrl.isNotEmpty
                                    ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                )
                                    : Container(color: Colors.grey), // Nếu không có ảnh, hiển thị container xám
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
                        );

                      }),
                    ),
                  )




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

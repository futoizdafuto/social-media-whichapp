import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:socially_app_flutter_ui/screens/profile/setting_profile/settinguser_profile_screen.dart';
import 'package:socially_app_flutter_ui/screens/profile/widgets/profile_background.dart';
import 'dart:math' as math;
import 'package:socially_app_flutter_ui/screens/profile/widgets/stat.dart';
import '../../data/repository/post_repository.dart';
import '../../services/BlockServices.dart';
import '../../services/FollowServices.dart';
import '../settings_modal/setting_item.dart';
import 'PostInProfileScreen.dart';
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
  String? realUserName;

  // Thêm các biến để lưu trữ số lượng followers và following
  int _followingCount = 0;
  int _followedCount = 0;
  int _postsCount = 0;
  bool _isBlocked = false;
  List<Map<String, dynamic>> _imageList = [];
  List<String> _followingList = [];
  List<String> _followedList = [];
  List<String> _waitingUseredList = [];
  late List<dynamic> _posts = []; // Initialize the _posts variable


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

  void checkIfBlocked() async {
    final blocksData = await BlockService().getBlock();  // Sử dụng BlockService
    if (blocksData['status'] == 'success') {
      final blockedUsers = blocksData['blocked_users'] as List;
      if (blockedUsers.contains(widget.username)) {
        setState(() {
          _isBlocked = true;
          _followingCount = 0;  // Đặt lại số lượng following
          _followedCount = 0;   // Đặt lại số lượng followers
        });
      } else {
        // Nếu không bị chặn, bạn có thể tiếp tục lấy thông tin bình thường
        fetchFollowData();  // Lấy dữ liệu follow bình thường
      }
    }
  }
  Future<String?> _getRealUserName() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'realuserName');  // Assuming realUserName is saved under this key
  }
  Future<void> _loadRealUserName() async {
    final username = await _getRealUserName();
    setState(() {
      realUserName = username;
    });
  }
  void _navigateToPostDetail(BuildContext context, String imageUrl, String username, String content, int postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Postinprofilescreen(
            postImage: imageUrl,
            username: username,
            content: content, postId: postId
        ),
      ),
    );
  }
  // Hàm lấy dữ liệu follow
  void fetchFollowData() async {
    if (_isBlocked) return;  // Nếu bị chặn, không thực hiện lấy dữ liệu follow

    final followService = FollowService();

    // Lấy thông tin follow cho người dùng theo username được truyền vào
    final followData = await followService.getFollowUser(widget.username);

    if (followData['status'] == 'success') {
      setState(() {
        _followingCount = followData['following_count'];
        _followedCount = followData['followed_count'];
        _followingList = List<String>.from(followData['following_list'] ?? []);
        _followedList = List<String>.from(followData['followed_list'] ?? []);
      });
    } else {
      print('Error: ${followData['message']}');
    }
  }

  void fetchWaitingUsered() async {
    final followService = FollowService();
    final waitingData = await followService.getWaitingUsed();

    if (waitingData['status'] == 'success') {
      setState(() {
        _waitingUseredList = List<String>.from(waitingData['waiting_usered'] ?? []);
      });
    } else {
      print('Error: ${waitingData['message']}');
    }
  }

  Future<void> fetchPostCount2() async {
    final postService = PostRepository();
    final realUserName = widget.username; // Lấy tên người dùng thực tế

    if (realUserName != null) {
      try {
        // Gọi hàm getCountPostByUsername để lấy số lượng bài viết của người dùng
        final postsResponse = await postService.getCountPostByUsername2(realUserName);

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

  Future<void> fetchImages2() async {
    final postService = PostRepository();
    final realUserName = widget.username; // Lấy tên người dùng thực tế

    if (realUserName != null) {
      try {
        final imagesResponse = await postService
            .getImagesByUsername2(realUserName); // Giả sử bạn đã tạo hàm getImagesByUsername
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
    fetchWaitingUsered();
    checkIfBlocked();
    fetchPostCount2();
    fetchImages2();
    _loadRealUserName();
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
                    builder: (context) => SettingUserProfileScreen(
                      username: widget.username, // Pass username from ProfileFollowScreen
                    ),
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
                  _isBlocked
                      ? Text(
                    'Đã bị chặn',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  )
                      : Text(
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
                        GestureDetector(
                          onTap: _isBlocked ? null : () async {
                            final followService = FollowService();
                            final followData = await followService.getFollowUser(widget.username);

                            if (followData['status'] == 'success') {
                              List<Follower> followedList = List<String>.from(followData['followed_list']).map((username) {
                                return Follower(
                                  name: username,
                                  subtitle: "Đang theo dõi bạn",
                                  profileImageUrl: "https://via.placeholder.com/150",
                                  isFollowing: false,
                                );
                              }).toList();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowUserListScreen(
                                    title: 'Followers',
                                    followers: followedList,
                                    suggestedUsers: [],
                                    showFollowButton: false, followingList: [],
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
                          onTap: _isBlocked ? null : () async {
                            final realUserName = widget.username;

                            final followService = FollowService();
                            final followData = await followService.getFollowUser(realUserName);

                            if (followData['status'] == 'success') {
                              List<String> originalFollowingList = List<String>.from(followData['following_list']);

                              List<Follower> suggestedUsers = await _fetchSuggestedUsers(originalFollowingList);

                              List<Follower> followingUsers = originalFollowingList.map((username) {
                                return Follower(
                                  name: username,
                                  subtitle: "",
                                  profileImageUrl: "https://via.placeholder.com/150",
                                  isFollowing: true,
                                );
                              }).toList();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FollowUserListScreen(
                                    title: 'Following',
                                    followers: followingUsers,
                                    suggestedUsers: suggestedUsers,
                                    showFollowButton: true, followingList: [],
                                  ),
                                ),
                              );
                            } else {
                              print('Error fetching following data: ${followData['message']}');
                            }
                          },
                          child: Stat(title: 'Following', value: _followingCount),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Buttons Section
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                          onPressed: () async {
                            FollowService followService = FollowService();

                            if (_followedList.contains(realUserName)) {
                              // Nếu đang theo dõi, thực hiện unfollow
                              final unfollowResponse = await followService.unfollowUser(widget.username);
                              if (unfollowResponse['status'] == 'success') {
                                setState(() {
                                  _followedList.remove(realUserName);
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Không thể bỏ theo dõi, vui lòng thử lại!')),
                                );
                              }
                            } else {
                              // Nếu chưa theo dõi, thực hiện kiểm tra trạng thái tài khoản
                              final statusData = await followService.getUserStatus(widget.username);

                              if (statusData['status'] == 'success') {
                                final isPrivate = statusData['private'];

                                if (isPrivate == true) {
                                  // Tài khoản riêng tư: hiển thị hộp thoại xác nhận
                                  bool? shouldFollow = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Tài khoản riêng tư'),
                                        content: Text(
                                          'Tài khoản này đang ở chế độ riêng tư. Bạn có muốn gửi yêu cầu theo dõi không?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false); // Không gửi yêu cầu
                                            },
                                            child: Text('Không'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true); // Gửi yêu cầu
                                            },
                                            child: Text('Có'),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (shouldFollow == true) {
                                    // Gửi yêu cầu theo dõi
                                    final followResponse = await followService.followUser(widget.username);
                                    if (followResponse['status'] == 'success') {
                                      setState(() {
                                        _waitingUseredList.add(widget.username); // Thêm vào danh sách chờ
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Không thể gửi yêu cầu theo dõi, vui lòng thử lại!')),
                                      );
                                    }
                                  }
                                } else {
                                  // Tài khoản công khai: theo dõi ngay
                                  final followResponse = await followService.followUser(widget.username);
                                  if (followResponse['status'] == 'success') {
                                    setState(() {
                                      _followedList.add(realUserName!); // Thêm vào danh sách đang theo dõi
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Không thể theo dõi, vui lòng thử lại!')),
                                    );
                                  }
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Không thể kiểm tra trạng thái tài khoản, vui lòng thử lại sau!')),
                                );
                              }
                            }
                          },
                          child: Text(
                            _followedList.contains(realUserName)
                                ? 'Đang theo dõi'
                                : _waitingUseredList.contains(widget.username)
                                ? 'Đang chờ chấp nhận'
                                : 'Theo dõi',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
                          onPressed: () {},
                          child: Text('Nhắn tin'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 50.0),

                  // Conditionally display the Grid of Posts
                  if (!_isBlocked)
                    Padding(
                      padding: const EdgeInsets.all(13.0),
                      child: StaggeredGrid.count(
                        crossAxisCount: 2, // Số cột trong grid
                        mainAxisSpacing: 14.0,
                        crossAxisSpacing: 14.0,
                        children: List.generate(_posts.length, (index) {
                          // Lấy bài đăng từ danh sách bài viết
                          final post = _posts[index];

                          // Lấy URL ảnh từ danh sách hình ảnh trong bài đăng
                          final imageUrls = post['image_urls'] ?? [];
                          final imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : ''; // Chọn ảnh đầu tiên nếu có

                          final username = post['user']?['username'] ?? 'Unknown User'; // Lấy username
                          final content = post['content'] ?? ''; // Lấy nội dung bài viết
                          final postid = post["post_id"];

                          return StaggeredGridTile.count(
                            crossAxisCellCount: 1,
                            mainAxisCellCount: 1.5,
                            child: GestureDetector(
                              onTap: () => _navigateToPostDetail(context, imageUrl, username, content,postid),
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

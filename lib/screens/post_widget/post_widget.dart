import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
// import 'package:flutter_svg/svg.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
// import 'package:socially_app_flutter_ui/data/models/post/mock_post.dart';
import 'package:socially_app_flutter_ui/data/models/post/post.dart';
import 'package:socially_app_flutter_ui/data/models/user/user.dart';
import 'package:socially_app_flutter_ui/screens/comment_model/comment_modal.dart';
import 'package:socially_app_flutter_ui/screens/post_widget/reaction_widget.dart';
import '../../cors/utils/handle_futureBuilder.dart';
import '../../data/repository/user_repository.dart';
import '../../data/repository/post_repository.dart';
import '../media_gallery/media.dart';
import '../settings_modal/setting_item.dart';
import 'package:video_player/video_player.dart';

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  // khởi tạo 1 đối tượng post từ repository
  final PostRepository postRepository =
      PostRepository(); // Khởi tạo PostRepository.
  late Future<List<Post>> posts;
  late final UserRepository userRepository = UserRepository();
  late Future<List<User>> users;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? avatarUrl;

  @override
  void initState() {
    super
        .initState(); // Gọi initState() của lớp cha (State) để đảm bảo các thiết lập hệ thống được thực hiện.
    posts = postRepository
        .fetchPost(); // Khởi tạo biến posts bằng cách gọi hàm fetchPosts().
    // users = userRepository.fetchUser();
    // Đọc avatarUrl từ storage trong initState
    _loadAvatar();
  }
  // Hàm để đọc avatar từ storage
  Future<void> _loadAvatar() async {
    String? avatar = await _storage.read(key: 'avatarUrl');
    setState(() {
      avatarUrl = avatar;
    });
  }
  // trạng thái active cho nút like
  bool isActive = false; // Trạng thái của icon
  // Hàm xử lý sự kiện khi chọn Setting
  static void _handleSetting(BuildContext context, String message) {
    Navigator.pop(context); // Đóng modal
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return HandleFuturebuilder<List<Post>>(
        future: posts,
        loadingWidget: const Center(child: CircularProgressIndicator()),
        errorWidget: const Center(child: Text('Error loading posts')),
        builder: (context, posts) {
          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              final post = posts[index];

              //trả về hàm dựng giao diện bài viết ở đây
              return _buildPostCard(context, size, post);
            },
          );
        });
  }

  // hàm để dựng giao diện bài viết
  Widget _buildPostCard(BuildContext context, Size size, Post post) {
    return Column(
      children: [
        _buildHeadingPost(post),
        Container(
            margin: const EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 0.5,
              right: 0.5,
            ),
            // padding: const EdgeInsets.all(14.0),
            // height: size.height * 0.40,
            width: double.infinity,
            decoration: BoxDecoration(
              // color: Colors.red,
              borderRadius: BorderRadius.circular(3),

              // image: const DecorationImage(
              //   image: AssetImage("assets/images/building-1.jpg"),
              //   fit: BoxFit.cover,
              // ),
            ),
            child: MediaCard(
              mediaList: post.mediaList,
            )
            // child: MediaGallery(mediaList: post.mediaList),
            ),

        /// de phan reaction o day
        _buildReactionButton(post),

        /// phần content
        _buildPostContent(post),
      ],
    );
  }

  // hàm để hiển thị tên người dùng, avatar và nút setting
  Widget _buildHeadingPost(Post post) {
    return Container(
      margin: const EdgeInsets.only(
        top: 30,
        left: 20,
        right: 0.5,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  avatarUrl != null
                  ? CircleAvatar(
                        backgroundImage: NetworkImage(post.user.avatar_url),
                        maxRadius: 25.0,
                      )
                    : const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 255, 255, 255), // Màu nền khi không có avatar
                        child: Icon(Icons.person, color: Color.fromARGB(255, 121, 121, 121)),
                        maxRadius: 16.0,
                      ),
                  const SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     Text(
                      post.user.name,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(
                            color: const Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.bold, // Làm cho chữ đậm
                            fontSize: 18.0, // Thay đổi kích thước chữ (có thể điều chỉnh theo ý muốn)
                          ),
                    ),

                  Text(
                    "${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year} ${post.createdAt.hour}:${post.createdAt.minute}:${post.createdAt.second}",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge!
                        .copyWith(color: k1Gray),
                  ),

                    ],
                  ),
                ],
              ),
              _buildSettingPostCard()
            ],
          ),
        ],
      ),
    );
  }

  // hàm để xử lý hiển thị setting của bài viết

  Widget _buildSettingPostCard() {
    return IconButton(
      icon: const Icon(Icons.more_vert, color: kBlack),
      onPressed: () {
        // Gọi modal với các tham số tùy chỉnh
        SettingsModal.show(
          context,
          items: [
            SettingItem(
              icon: Icons.edit,
              title: 'Sửa bài viết',
              onTap: () => _handleSetting(context, 'Setting 1 selected'),
            ),
            SettingItem(
              icon: Icons.delete,
              title: 'Xóa bài viết',
              onTap: () => _handleSetting(context, 'Setting 2 selected'),
            ),
          ],
        );
      },
    );
  }

  // hàm build like và commenr
Widget _buildReactionButton(Post post) {
  return Container(
    padding: const EdgeInsets.only(left: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        PostStat(
          iconPath: 'assets/icons/favorite_border.svg',
          activeIconPath: 'assets/icons/favorite_heart.svg',
          value: post.likeCount,
          userId: post.user.user_id,
          postId: post.postId, // Truyền ID bài viết
          post: post,
          onTap: () {
            //print("Liked the post!");
          },
          isLikeButton: true,
          isActive: false, // Gán trạng thái hiện tại nếu có
        ),
        PostStat(
          iconPath: 'assets/icons/comments.svg',
          activeIconPath: '',
          value: post.commentCount,
          userId: post.user.user_id,
          postId: post.postId, // Truyền ID bài viết
          post: post,
          onTap: () {
            CommentModal.show(
              context, 
              post, 
              () {
                setState(() {
                  post.commentCount++; // Tăng số lượng bình luận lên
                });
              },
            );
          },
          isLikeButton: false,
        ),
      ],
    ),
  );
}

  // hàm hiển thị phần content( text ) của bài viết
  Widget _buildPostContent(Post post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1.0,
          ),
        ),
      ), // Căn chỉnh nội dung Container sang trái
      child: Container(
        padding: const EdgeInsets.only(bottom: 3),
        child: Text(
          post.content,
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
  // @override
  // void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  //   super.debugFillProperties(properties);
  //   properties.add(IterableProperty<String>('mediaList', mediaList));
  // }
}

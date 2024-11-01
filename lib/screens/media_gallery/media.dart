import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../data/models/post/post.dart'; // Thêm package video_player vào pubspec.yaml

class MediaGallery extends StatelessWidget {
  final List<Media> mediaList;

  const MediaGallery({Key? key, required this.mediaList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: mediaList.length,
      itemBuilder: (context, index) {
        final media = mediaList[index];
        return media.mediaUrl.endsWith('.mp4') // Kiểm tra định dạng video
            ? VideoPlayerWidget(videoUrl: media.mediaUrl)
            : Image.network(media.mediaUrl); // Hiển thị hình ảnh
      },
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : Container(); // Hiện tại chưa khởi tạo video
  }
}

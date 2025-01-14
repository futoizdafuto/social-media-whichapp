import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:async';

import '../../config/colors.dart';
import '../../data/models/post/post.dart';


// bug khi slide qua ảnh thì video vẫn còn được bật
class MediaCard extends StatefulWidget {
  const MediaCard({
    super.key,
    required this.mediaList,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  final List<Media> mediaList;
  final int maxRetries;
  final Duration retryDelay;

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  VideoPlayerController? _videoController;
  int _currentIndex = 0;
  int _retryCount = 0;
  Timer? _retryTimer;
  bool _isRetrying = false;
  final bool _isVideoPlaying = false;
  bool _showControls = true; // Thêm biến điều khiển hiển thị
  late Timer _controlsHideTimer; // Timer để ẩn control

  @override
  void initState() {
    super.initState();
    _initializeMedia();
    // Khởi tạo _controlsHideTimer khi initState
    _controlsHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _retryTimer?.cancel();
    _controlsHideTimer.cancel(); // Hủy bỏ Timer khi dispose
    super.dispose();
  }

  Future<void> _initializeMedia() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    if (_isVideo(widget.mediaList[_currentIndex].mediaUrl)) {
      await _initializeVideo(widget.mediaList[_currentIndex].mediaUrl);
    } else {
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    }
  }

  bool _isVideo(String mediaUrl) {
    return mediaUrl.toLowerCase().endsWith('.mp4');
  }

  Future<void> _initializeVideo(String mediaUrl) async {
    await _videoController?.dispose();
    _retryCount = 0;
    await _attemptVideoInitialization(mediaUrl);
  }

  Future<void> _attemptVideoInitialization(String mediaUrl) async {
    if (!mounted) return;

    try {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 30)
        ..badCertificateCallback = ((_, __, ___) => true);

      final request = await client
          .getUrl(Uri.parse(mediaUrl))
          .timeout(const Duration(seconds: 30));
      final response =
          await request.close().timeout(const Duration(seconds: 30));

      final tempDir = await Directory.systemTemp.createTemp('video_cache');
      final tempFile = File('${tempDir.path}/temp_video.mp4');

      await response.pipe(tempFile.openWrite());

      if (!mounted) return;

      _videoController = VideoPlayerController.file(tempFile);

      await _videoController!.initialize();

      // Tự động phát video khi video được khởi tạo
      _videoController!.play();

      // Lắng nghe sự thay đổi của video để cập nhật thanh tiến trình
      _videoController!.addListener(() {
        if (_videoController!.value.isInitialized) {
          setState(() {});
        }
      });

      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = false;
          _isRetrying = false;
        });
      }
    } catch (error) {
      if (!mounted) return;

      if (_retryCount < widget.maxRetries) {
        _retryCount++;
        setState(() {
          _isRetrying = true;
          _errorMessage =
              'Retrying... Attempt $_retryCount of ${widget.maxRetries}';
        });

        _retryTimer = Timer(widget.retryDelay, () {
          if (mounted) {
            _attemptVideoInitialization(mediaUrl);
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _isRetrying = false;
          _errorMessage =
              'Failed to load media after ${widget.maxRetries} attempts.\nError: $error';
        });
      }
    }
  }

  Future<void> _retryCurrentMedia() async {
    _retryCount = 0;
    _initializeMedia();
  }

  void _onSwipe(DragEndDetails details) {
    if (details.primaryVelocity == null) return;

    if (details.primaryVelocity! < 0 &&
        _currentIndex < widget.mediaList.length - 1) {
      setState(() {
        _currentIndex++;
        _initializeMedia();
      });
    } else if (details.primaryVelocity! > 0 && _currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _initializeMedia();
      });
    }
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
    // Reset timer mỗi khi người dùng tương tác
    _controlsHideTimer.cancel();
    _controlsHideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kWhite,
      child: Center(
        child: GestureDetector(
          onHorizontalDragEnd: _onSwipe,
          onTap:
              _toggleControlsVisibility, // Hiện/ẩn điều khiển khi người dùng click vào
          child: SizedBox(
            height: 350,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _buildMediaContent(),
                ),
                // _buildPageIndicator(),
                if (_isVideo(widget.mediaList[_currentIndex].mediaUrl))
                  _buildMediaControls(), // Chỉ hiển thị control khi là video
              ],
            ),
          ),
        ),
      ),
    );
  }

//   @override
// Widget build(BuildContext context) {
//   return Container(
//     color: Colors.white.withOpacity(0.1),
//     child: Center(
//       child: GestureDetector(
//         onHorizontalDragEnd: _onSwipe,
//         onTap: _toggleControlsVisibility, // Hiện/ẩn điều khiển khi người dùng click vào
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // Cho phép Column chỉ chiếm không gian cần thiết
//           children: [
//             Stack(
//               fit: StackFit.loose, // Cho phép Stack tự điều chỉnh kích thước theo nội dung
//               children: [
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 500),
//                   transitionBuilder: (child, animation) {
//                     return FadeTransition(opacity: animation, child: child);
//                   },
//                   child: _buildMediaContent(),
//                 ),
//                 if (_isVideo(widget.mediaList[_currentIndex].mediaUrl))
//                   _buildMediaControls(), // Chỉ hiển thị control khi là video
//               ],
//             ),
//             // Các phần khác như tiêu đề, phản hồi, nội dung bài viết
//             _buildReactionButton(post),
//             _buildPostContent(post),
//           ],
//         ),
//       ),
//     ),
//   );
// }

  Widget _buildMediaContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            if (_isRetrying) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _retryCurrentMedia,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_isVideo(widget.mediaList[_currentIndex].mediaUrl)) {
      return _videoController?.value.isInitialized == true
          ? AspectRatio(
              key: ValueKey<String>('video_$_currentIndex'),
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
          : const SizedBox.shrink();
    }

    // Sử dụng ClipRect để cắt phần hình ảnh vượt quá chiều rộng và chiều cao của container
    return ClipRect(
      child: Align(
        alignment: Alignment.center, // Căn giữa hình ảnh
        child: SizedBox(
          width: double.infinity, // Chiều rộng đầy đủ
          height: 400, // Chiều cao cố định
          child: Image.network(
            widget.mediaList[_currentIndex].mediaUrl,
            key: ValueKey<String>('image_$_currentIndex'),
            fit: BoxFit.cover, // Hình ảnh sẽ tự động cắt để vừa với container
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retryCurrentMedia,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMediaControls() {
    if (_videoController?.value.isInitialized != true) {
      return const SizedBox.shrink();
    }

    final position = _videoController!.value.position;
    final duration = _videoController!.value.duration;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: _showControls ? 0 : -100, // Ẩn/hiện control
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black.withOpacity(0.6),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
              child: Slider(
                value: position.inSeconds.toDouble(),
                min: 0,
                max: duration.inSeconds.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _videoController!.seekTo(Duration(seconds: value.toInt()));
                  });
                },
              ),
            ),
            SizedBox(
              height: 25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.fast_rewind,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () {
                      final currentPosition = _videoController!.value.position;
                      final newPosition =
                          currentPosition - const Duration(seconds: 5);
                      _seekTo(newPosition);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      _videoController!.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_videoController!.value.isPlaying) {
                          _videoController!.pause();
                        } else {
                          _videoController!.play();
                        }
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.fast_forward,
                      color: Colors.white,
                      size: 16,
                    ),
                    onPressed: () {
                      final currentPosition = _videoController!.value.position;
                      final newPosition =
                          currentPosition + const Duration(seconds: 5);
                      _seekTo(newPosition);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _seekTo(Duration newPosition) {
    final maxDuration = _videoController!.value.duration;

    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    } else if (newPosition > maxDuration) {
      newPosition = maxDuration;
    }

    _videoController!.seekTo(newPosition);
  }

  Widget _buildPageIndicator() {
    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(
            widget.mediaList.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CircleAvatar(
                radius: 5,
                backgroundColor: _currentIndex == index
                    ? kBlack
                    : Colors.white.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

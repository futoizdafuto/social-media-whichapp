import 'package:flutter/material.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';

import '../../data/models/post/post.dart';
import '../../data/repository/post_repository.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
 

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng bài'),
        backgroundColor: k2MainThemeColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TextField để nhập nội dung bài đăng
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(
                      labelText: 'Nhập nội dung bài viết...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    maxLines: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập nội dung bài viết';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),

                  // Nút chọn ảnh
                  ElevatedButton.icon(
                    onPressed: () {
                      // Chọn ảnh từ thư viện hoặc camera
                    },
                    icon: const Icon(Icons.photo),
                    label: const Text('Chọn ảnh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      minimumSize: Size(size.width * 0.75, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Nút chọn video
                  ElevatedButton.icon(
                    onPressed: () {
                      // Chọn video từ thư viện hoặc camera
                    },
                    icon: const Icon(Icons.videocam),
                    label: const Text('Chọn video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      minimumSize: Size(size.width * 0.75, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),

                  // Nút đăng bài
                  GestureDetector(
                    onTap: () {
                      // Kiểm tra nếu các trường không hợp lệ
                      if (_formKey.currentState!.validate()) {
                        // Gửi nội dung bài đăng
                      }
                    },
                    child: Container(
                      width: size.width * 0.75,
                      height: 55.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: k2MainThemeColor,
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      child: Text(
                        'Đăng bài',
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: Colors.white,
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

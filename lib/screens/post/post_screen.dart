import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:socially_app_flutter_ui/config/colors.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Assuming you're using this package for secure storage
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:socially_app_flutter_ui/data/repository/post_repository.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? _selectedImage; // Variable to store the selected image
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Secure storage instance

  // Method to request permission and select an image
  Future<void> _selectImage() async {
    final PermissionState permissionStatus = await PhotoManager.requestPermissionExtend();

    if (permissionStatus == PermissionState.authorized) {
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true);
      if (albums.isNotEmpty) {
        final List<AssetEntity> assets = await albums[0].getAssetListRange(start: 0, end: 100);

        final selectedAsset = await showModalBottomSheet<File?>(
          context: context,
          builder: (context) => ImagePickerModal(assets: assets),
        );

        if (selectedAsset != null) {
          setState(() {
            _selectedImage = selectedAsset;
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No permission to access photos')),
      );
    }
  }

  // Method to handle the post submission
  Future<void> _postContent() async {
    if (_formKey.currentState!.validate() && _selectedImage != null) {
      // Get the userId from storage
      String? userId = await _storage.read(key: 'userId');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      String content = _contentController.text;

      // Call uploadPost method
      List<File> files = [_selectedImage!];
      PostRepository postRepository = new PostRepository();
      var result = await postRepository.uploadPost(int.parse(userId), files, content);

      if (result['status'] == 'success') {
        // Show success message and navigate to home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post uploaded successfully')),
        );
        Navigator.pop(context); // Close the current screen and go back to the main screen
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['message']}')),
        );
      }
    }
  }

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
                  // TextField to enter post content
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

                  // Display selected image if any
                  if (_selectedImage != null)
                    Image.file(
                      _selectedImage!,
                      height: 150.0,
                      width: size.width * 0.75,
                      fit: BoxFit.cover,
                    ),
                  const SizedBox(height: 20.0),

                  // Button to select image
                  ElevatedButton.icon(
                    onPressed: _selectImage, // Call select image method
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

                  // Submit post button
                  GestureDetector(
                    onTap: _postContent, // Handle post submission
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
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(
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

// Modal to display images for selection
class ImagePickerModal extends StatelessWidget {
  final List<AssetEntity> assets;

  const ImagePickerModal({Key? key, required this.assets}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: assets.length,
        itemBuilder: (context, index) {
          final asset = assets[index];
          return FutureBuilder<File?>(
            future: asset.file,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, snapshot.data); // Return selected image
                  },
                  child: Image.file(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  ),
                );
              } else {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                );
              }
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:socially_app_flutter_ui/screens/login/login_screen.dart';
import 'package:socially_app_flutter_ui/screens/nav/nav.dart';
import 'package:socially_app_flutter_ui/services/LoginServices.dart';

class UserInfo {
  String? gender;
  String? birthDate;
  File? avatar;

  UserInfo({this.gender, this.birthDate, this.avatar});

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'birthDate': birthDate,
      'avatar': avatar != null ? avatar!.path : null,
    };
  }
}
final LoginService _loginService = LoginService();
class GenderSelectionScreen extends StatelessWidget {
final UserInfo userInfo = UserInfo();

  GenderSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Giới Tính'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chọn giới tính của bạn:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                userInfo.gender = 'Male';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                     builder: (context) => BirthDateSelectionScreen(userInfo: userInfo),
                  ),
                );
              },
            icon: const Icon(
              Icons.male,
              color: Color.fromARGB(255, 0, 0, 0), 
            ),
            label: const Text('Nam'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Màu xanh dương cho nút
              foregroundColor: Colors.white, // Màu chữ
            ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                userInfo.gender = 'Female';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BirthDateSelectionScreen(userInfo: userInfo),
                  ),
                );
              },
             icon: const Icon(
              Icons.female,
              color: Color.fromARGB(255, 0, 0, 0), // Màu hồng cho icon
            ),
            label: const Text('Nữ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink, // Màu hồng cho nút
              foregroundColor: Colors.white, // Màu chữ
            ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                userInfo.gender = 'Other';
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BirthDateSelectionScreen(userInfo: userInfo),
                  ),
                );
              },
              icon: const Icon(Icons.transgender),
              label: const Text('Khác'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
          },
          child: const Text('Quay lại'),
        ),
      ),
    );
  }
}

class BirthDateSelectionScreen extends StatefulWidget {
  final UserInfo userInfo;

  const BirthDateSelectionScreen({Key? key, required this.userInfo}) : super(key: key);


  @override
  _BirthDateSelectionScreenState createState() => _BirthDateSelectionScreenState();
}

class _BirthDateSelectionScreenState extends State<BirthDateSelectionScreen> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Ngày Sinh'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chọn sinh nhật của bạn:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                   
                  });
                }
              },
              child: const Text('Chọn Ngày Sinh'),
            ),
            if (selectedDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  'Ngày đã chọn: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
             onPressed: () {
                // Quay lại mà không mất dữ liệu đã chọn (gender)
                Navigator.pop(context, widget.userInfo); // Trả lại userInfo đã cập nhật
              },
              child: const Text('Quay lại'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedDate != null) {
                  String formattedDates = '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
                widget.userInfo.birthDate = formattedDates; // Gán giá trị vào userInfo

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AvatarSelectionScreen(userInfo: widget.userInfo),
                  ),
                    );
                } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng chọn ngày sinh!')),
                  );
                }
              },
              child: const Text('Tiếp theo'),
            ),
          ],
        ),
      ),
    );
  }
}

class AvatarSelectionScreen extends StatefulWidget {
  final UserInfo userInfo;

  const AvatarSelectionScreen({Key? key, required this.userInfo}) : super(key: key);

  @override
  _AvatarSelectionScreenState createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen> {
  File? _selectedImage;

  Future<void> _showImagePickerModal(BuildContext context) async {
    final result = await showModalBottomSheet<File?>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const ImagePickerModal(),
    );
    if (result != null) {
      setState(() {
        _selectedImage = result;
        widget.userInfo.avatar = result; // Cập nhật avatar trong UserInfo
      });
    }
  }

  Future<void> _submitData() async {
    // Lấy userId từ _loginService
  final userIdString = await _loginService.getUserId();
  if (userIdString == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Không thể lấy thông tin người dùng')),
    );
    return;
  }

  final userId = int.tryParse(userIdString);
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User ID không hợp lệ')),
    );
    return;
  }

    final response = await _loginService.updateInformation(
      userId: userId, // Thay bằng ID người dùng thực tế
      gender: widget.userInfo.gender,
      birthDate: widget.userInfo.birthDate,
      avatarFile: widget.userInfo.avatar,
    );

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thành công!')),
      );
         // Chuyển hướng đến trang Nav
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Nav()),
    );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${response['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Ảnh Đại Diện'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  _selectedImage != null ? FileImage(_selectedImage!) : null,
              child: _selectedImage == null
                  ? const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.grey,
                    )
                  : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showImagePickerModal(context),
              child: const Text('Tải Ảnh Lên'),
            ),
            const SizedBox(height: 10),
           TextButton(
             onPressed: () async {
              // Đặt avatar là null khi bấm bỏ qua
              setState(() {
                widget.userInfo.avatar = null; // Đặt avatar thành null
              });

              // Gọi phương thức _submitData để gửi dữ liệu mà không có avatar
              await _submitData();
            },
            child: const Text('Bỏ Qua'),
          ),
          ],
        ),
      ),
         bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Quay lại'),
            ),
            ElevatedButton(
              onPressed: _submitData,
            
              child: const Text('Tiếp theo'),
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePickerModal extends StatefulWidget {
  const ImagePickerModal({Key? key}) : super(key: key);

  @override
  _ImagePickerModalState createState() => _ImagePickerModalState();
}

class _ImagePickerModalState extends State<ImagePickerModal> {
  List<AssetEntity>? _images;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final PermissionState status = await PhotoManager.requestPermissionExtend();

    if (status == PermissionState.authorized) {
      final List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(onlyAll: true);
      if (albums.isNotEmpty) {
        final List<AssetEntity> images =
            await albums[0].getAssetListRange(start: 0, end: 100);
        setState(() {
          _images = images;
          _isLoading = false;
        });
      } else {
        setState(() {
          _images = [];
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _images = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _images == null || _images!.isEmpty
              ? const Center(child: Text('Không tìm thấy ảnh nào.'))
              : GridView.builder(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: _images!.length,
                  itemBuilder: (context, index) {
                    final image = _images![index];
                    return FutureBuilder<File?>(
                      future: image.file,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(context, snapshot.data);
                            },
                            child: Image.file(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                          
                        );
                      },
                    );
                  },
                ),
    );
  }
}
class RegistrationCompletedScreen extends StatelessWidget {
  const RegistrationCompletedScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoàn Thành Đăng Ký'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Đăng ký thành công!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Về Trang Chính'),
            ),
          ],
        ),
      ),
    );
  }
}

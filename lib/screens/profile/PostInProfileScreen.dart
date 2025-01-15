import 'dart:ffi';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../data/repository/post_repository.dart';

class Postinprofilescreen extends StatefulWidget {
  final String username;
  final String postImage;
  String content; // Make content mutable to update it
  final int postId; // PostId to identify the post for updating

  Postinprofilescreen({
    Key? key,
    required this.postImage,
    required this.username,
    required this.content, // Accept mutable content
    required this.postId,
  }) : super(key: key);

  @override
  _PostinprofilescreenState createState() => _PostinprofilescreenState();
}

class _PostinprofilescreenState extends State<Postinprofilescreen> {
  bool _isEditing = false; // Flag to check whether the user is editing the post
  bool _isInSettingsMode = true; // Flag to track if in settings mode
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.content); // Initialize with current content
  }

  // Function to handle editing the post
  void _handleEditPost() {
    setState(() {
      _isEditing = true; // Switch to editing mode
      _isInSettingsMode = false; // Exit settings mode
    });
  }

  // Function to update the post
  Future<void> _updatePost() async {
    final newContent = _contentController.text; // Get new content from the controller
    final postService = PostRepository();

    // Call the updatePost method with postId and the new content
    final result = await postService.updatePost(widget.postId, newContent);

    if (result['status'] == 'success') {
      // After successful update, update content and switch back to view mode
      setState(() {
        widget.content = newContent; // Update the content to the new one
        _isEditing = false; // Switch back to non-editable mode
        _isInSettingsMode = true; // Return to settings mode
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post updated successfully')),
      );
    } else {
      setState(() {
        widget.content = newContent; // Update the content to the new one
        _isEditing = false; // Switch back to non-editable mode
        _isInSettingsMode = true; // Return to settings mode
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating post')),
      );
    }
  }

  // Function to delete post
  Future<void> _deletePost() async {
    final postService = PostRepository();
    final result = await postService.deletePost(widget.postId); // Call the deletePost method

    if (result['status'] == 'success') {
      // If deletion is successful, show a confirmation message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
      Navigator.pop(context); // Go back to previous screen (profile screen)
    } else {
      // If there was an error, show the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
      Navigator.pop(context); // Go back to previous screen (profile screen)
    }
  }

  // Show Settings Modal
  void _showSettingsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows for a smaller height based on content
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          height: 150, // Adjust height as necessary
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Sửa bài viết'),
                onTap: () {
                  Navigator.pop(context); // Close settings modal
                  _handleEditPost(); // Switch to edit mode
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Xóa bài viết'),
                onTap: () {
                  Navigator.pop(context); // Close settings modal
                  _showDeleteConfirmationDialog(context); // Show confirmation dialog
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xóa bài viết'),
          content: Text('Bạn có chắc muốn xóa bài viết này không?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without doing anything
              },
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _deletePost(); // Proceed with deleting the post
              },
              child: Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _contentController.dispose(); // Dispose of the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Bài viết",
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
        actions: [
          // Toggle the icon based on whether we're in settings mode or editing mode
          if (_isInSettingsMode) // If not in editing mode
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.black),
              onPressed: () => _showSettingsModal(context), // Show settings modal
            )
          else if (_isEditing) // If in editing mode
            IconButton(
              icon: Icon(Icons.check, color: Colors.black),
              onPressed: _updatePost, // Save the post when clicked
            )
          else // If we are in settings mode but clicked on "Sửa bài viết"
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black),
              onPressed: _handleEditPost, // Allow editing the post
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.postImage),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.username,
                      style: TextStyle(color: Colors.black, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),

            // Post Image
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.postImage),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: Row(
                children: [
                  Icon(Icons.favorite_border, color: Colors.black),
                  SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => showCommentSection(context),
                    child: Icon(Icons.comment, color: Colors.black),
                  ),
                  SizedBox(width: 15),
                  Icon(Icons.send, color: Colors.black),
                  Spacer(),
                  Icon(Icons.bookmark_border, color: Colors.black),
                ],
              ),
            ),

            // Likes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(
                "Có ry_n6262 thích",
                style: TextStyle(color: Colors.black),
              ),
            ),

            // Content (If editing, use TextField; otherwise, just Text)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: _isEditing
                  ? TextField(
                controller: _contentController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: "Enter new content...",
                  border: OutlineInputBorder(),
                ),
              )
                  : RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "${widget.username} ",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(
                      text: widget.content,
                      style: TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),

            // Time Ago
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: Text(
                "4 ngày trước",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to display the comment section
  void showCommentSection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Comment Header
              Container(
                height: 4,
                width: 40,
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    // Sample comment
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        "ry_n6262",
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "🔥🔥",
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: Text(
                        "4 ngày",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),
              // Comment Input Section
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Bình luận...",
                        hintStyle: TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.blue),
                    onPressed: () {
                      // Handle comment sending
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Class chứa thông tin mỗi setting item
import 'package:flutter/material.dart';

// Class chứa thông tin mỗi setting item
class SettingItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  SettingItem({required this.icon, required this.title, required this.onTap});
}

// Modal Settings Widget
class SettingsModal {
  // Hàm static để hiển thị modal với danh sách SettingItem động
  static Future<void> show(BuildContext context,
      {required List<SettingItem> items}) async {
    return showModalBottomSheet(
      context: context,
      builder: (context) => _SettingsContent(items: items),
    );
  }
}

// Nội dung của Modal
class _SettingsContent extends StatelessWidget {
  final List<SettingItem> items;

  const _SettingsContent({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...items.map((item) => ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                onTap: item.onTap,
              )),
        ],
      ),
    );
  }
}

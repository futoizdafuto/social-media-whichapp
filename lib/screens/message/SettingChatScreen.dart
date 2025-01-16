import 'package:flutter/material.dart';

import 'CreateGroupScreen.dart';
import 'GroupListScreen.dart';

class SettingChatScreen extends StatelessWidget {
  const SettingChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16.0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Group Settings',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displayLarge!.copyWith(
              fontSize: 22.0,
              color: const Color.fromARGB(255, 1, 16, 43),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16.0),
          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text('Create Group'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
              );
              print('Create Group');
            },
          ),
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text('Group List'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GroupListScreen()),
              );
              print('Navigate to Group List');
            },
          ),
        ],
      ),
    );
  }
}
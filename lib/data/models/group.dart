import 'dart:convert';

class Group {
  final int roomId;
  final String name;
  final String? description;
  final String? avatar;
  final DateTime createdAt;

  Group({
    required this.roomId,
    required this.name,
    this.description,
    this.avatar,
    required this.createdAt,
  });

  // Factory method to create a Group from JSON
  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      roomId: json['roomId'],
      name: json['name'],
      description: json['description'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Static method to parse the response JSON and return a list of groups
  static List<Group> parseGroups(String responseBody) {
    final parsedJson = jsonDecode(responseBody);
    final groupsJson = parsedJson['getUserGroups']['data']['groups'] as List;

    return groupsJson.map((groupJson) => Group.fromJson(groupJson)).toList();
  }

  @override
  String toString() {
    return 'Group(roomId: $roomId, name: $name, description: $description, avatar: $avatar, createdAt: $createdAt)';
  }
}

// lib/core/event_categories.dart

import 'package:flutter/material.dart';

class EventCategoryData {
  final String name;
  final IconData icon;
  final Color color;

  EventCategoryData({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class EventCategories {
  static List<EventCategoryData> getAll() {
    return [
      EventCategoryData(
        name: 'Music',
        icon: Icons.music_note,
        color: Colors.purple,
      ),
      EventCategoryData(
        name: 'Sports',
        icon: Icons.sports_soccer,
        color: Colors.blue,
      ),
      EventCategoryData(name: 'Tech', icon: Icons.computer, color: Colors.cyan),
      EventCategoryData(
        name: 'Food',
        icon: Icons.restaurant,
        color: Colors.orange,
      ),
      EventCategoryData(name: 'Art', icon: Icons.palette, color: Colors.pink),
      EventCategoryData(
        name: 'Education',
        icon: Icons.school,
        color: Colors.teal,
      ),
      EventCategoryData(
        name: 'Social',
        icon: Icons.people,
        color: Colors.green,
      ),
      EventCategoryData(
        name: 'Other',
        icon: Icons.category,
        color: Colors.grey,
      ),
    ];
  }

  static Map<String, dynamic> getCategoryInfo(String categoryName) {
    final category = getAll().firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => getAll().last,
    );
    return {
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
    };
  }
}

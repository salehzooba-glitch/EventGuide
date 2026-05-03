import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/event_model.dart';

class CategoryChip extends StatelessWidget {
  final EventCategory? category;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    this.category,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryBlue
              // ignore: deprecated_member_use
              : AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primaryBlue,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Get icon for category
  static IconData getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.music:
        return Icons.music_note;
      case EventCategory.sports:
        return Icons.sports_soccer;
      case EventCategory.tech:
        return Icons.computer;
      case EventCategory.food:
        return Icons.restaurant;
      case EventCategory.art:
        return Icons.palette;
      case EventCategory.education:
        return Icons.school;
      case EventCategory.social:
        return Icons.people;
      case EventCategory.other:
        return Icons.event;
    }
  }

  // Get display name for category
  static String getCategoryName(EventCategory category) {
    switch (category) {
      case EventCategory.music:
        return 'Music';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.tech:
        return 'Technology';
      case EventCategory.food:
        return 'Food & Drink';
      case EventCategory.art:
        return 'Art';
      case EventCategory.education:
        return 'Education';
      case EventCategory.social:
        return 'Social';
      case EventCategory.other:
        return 'Other';
    }
  }
}

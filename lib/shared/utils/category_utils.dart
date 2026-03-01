import 'package:flutter/material.dart';

class CategoryUtils {
  static IconData getIconForCategory(String? name) {
    if (name == null) return Icons.category_rounded;
    String lower = name.toLowerCase();
    if (lower.contains('food') || lower.contains('restaurant') || lower.contains('eat')) return Icons.restaurant_rounded;
    if (lower.contains('shopping') || lower.contains('buy') || lower.contains('bag')) return Icons.shopping_bag_rounded;
    if (lower.contains('travel') || lower.contains('trip') || lower.contains('flight') || lower.contains('car')) return Icons.directions_car_rounded;
    if (lower.contains('bill') || lower.contains('electric') || lower.contains('utility') || lower.contains('wifi')) {
      return Icons.receipt_long_rounded;
    }
    if (lower.contains('health') || lower.contains('medical') || lower.contains('doctor')) return Icons.medical_services_rounded;
    if (lower.contains('salary') || lower.contains('income') || lower.contains('pay')) return Icons.payments_rounded;
    if (lower.contains('gift') || lower.contains('present')) return Icons.card_giftcard_rounded;
    if (lower.contains('movie') || lower.contains('fun') || lower.contains('entertainment')) return Icons.movie_creation_rounded;
    if (lower.contains('rent') || lower.contains('home')) return Icons.home_rounded;
    if (lower.contains('gym') || lower.contains('sport')) return Icons.fitness_center_rounded;
    if (lower.contains('education') || lower.contains('book') || lower.contains('school')) return Icons.school_rounded;
    return Icons.category_rounded;
  }
}

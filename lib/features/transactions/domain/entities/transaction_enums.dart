import 'package:flutter/material.dart';

enum TransactionType { credit, debit, unknown }

enum TransactionCategory {
  food,
  shopping,
  transport,
  entertainment,
  utilities,
  health,
  education,
  travel,
  fuel,
  groceries,
  emi,
  investment,
  salary,
  transfer,
  cashback,
  recharge,
  subscription,
  other;

  String get displayName {
    return switch (this) {
      TransactionCategory.food => 'Food & Dining',
      TransactionCategory.shopping => 'Shopping',
      TransactionCategory.transport => 'Transport',
      TransactionCategory.entertainment => 'Entertainment',
      TransactionCategory.utilities => 'Utilities',
      TransactionCategory.health => 'Health & Medical',
      TransactionCategory.education => 'Education',
      TransactionCategory.travel => 'Travel',
      TransactionCategory.fuel => 'Fuel',
      TransactionCategory.groceries => 'Groceries',
      TransactionCategory.emi => 'EMI / Loan',
      TransactionCategory.investment => 'Investment',
      TransactionCategory.salary => 'Salary',
      TransactionCategory.transfer => 'Transfer',
      TransactionCategory.cashback => 'Cashback / Reward',
      TransactionCategory.recharge => 'Recharge & Bills',
      TransactionCategory.subscription => 'Subscriptions',
      TransactionCategory.other => 'Other',
    };
  }

  String get emoji {
    return switch (this) {
      TransactionCategory.food => '🍔',
      TransactionCategory.shopping => '🛍️',
      TransactionCategory.transport => '🚗',
      TransactionCategory.entertainment => '🎬',
      TransactionCategory.utilities => '💡',
      TransactionCategory.health => '💊',
      TransactionCategory.education => '📚',
      TransactionCategory.travel => '✈️',
      TransactionCategory.fuel => '⛽',
      TransactionCategory.groceries => '🛒',
      TransactionCategory.emi => '🏦',
      TransactionCategory.investment => '📈',
      TransactionCategory.salary => '💰',
      TransactionCategory.transfer => '🔄',
      TransactionCategory.cashback => '🎁',
      TransactionCategory.recharge => '📱',
      TransactionCategory.subscription => '📺',
      TransactionCategory.other => '💳',
    };
  }

  Color get color {
    return switch (this) {
      TransactionCategory.food => const Color(0xFFFFB74D), // Orange
      TransactionCategory.shopping => const Color(0xFFBA68C8), // Purple
      TransactionCategory.transport => const Color(0xFF4FC3F7), // Light Blue
      TransactionCategory.entertainment => const Color(0xFFFF1744), // Red
      TransactionCategory.utilities => const Color(0xFF7986CB), // Indigo
      TransactionCategory.health => const Color(0xFFE57373), // Reddish
      TransactionCategory.education => const Color(0xFF81C784), // Green
      TransactionCategory.travel => const Color(0xFF4DB6AC), // Teal
      TransactionCategory.fuel => const Color(0xFFFFD54F), // Amber
      TransactionCategory.groceries => const Color(0xFFAED581), // Light Green
      TransactionCategory.emi => const Color(0xFF78909C), // Blue Grey
      TransactionCategory.investment => const Color(0xFF4CAF50), // Green
      TransactionCategory.salary => const Color(0xFF00C853), // Bright Green
      TransactionCategory.transfer => const Color(0xFF90A4AE), // Grey Blue
      TransactionCategory.cashback => const Color(0xFFF06292), // Pink
      TransactionCategory.recharge => const Color(0xFF42A5F5), // Blue
      TransactionCategory.subscription => const Color(
        0xFFFFAB40,
      ), // Dark Orange
      TransactionCategory.other => const Color(0xFF9E9E9E), // Grey
    };
  }
}

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
}

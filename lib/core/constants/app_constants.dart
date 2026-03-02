class AppConstants {
  AppConstants._();

  static const String appName = 'SpendSense';
  static const String appVersion = '1.0.0';

  // Firestore collections
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String categoriesCollection = 'categories';

  // SharedPreferences Keys
  static const String themeKey = 'theme_mode';
  static const String currencyKey = 'currency';
  static const String onboardingKey = 'onboarding_done';

  // Default values
  static const String defaultCurrency = '₹';
  static const String defaultCurrencyCode = 'INR';

  // Notification listener
  static const List<String> bankSenderKeywords = [
    'HDFC', 'ICICI', 'SBI', 'AXIS', 'KOTAK', 'BOI', 'PNB', 'CANARA',
    'INDUS', 'YES', 'PAYTM', 'PHONEPE', 'GPAY', 'AMAZON', 'AIRTEL',
    'YESBANK', 'IDFC', 'FEDERAL', 'UNION', 'BANK', 'UPI', 'NEFT', 'IMPS',
  ];
}

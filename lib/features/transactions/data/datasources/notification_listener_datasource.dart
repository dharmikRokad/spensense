import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notification_listener_service/notification_event.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/gemini_transaction_parser.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/transaction_entity.dart';

/// Service that listens to Android notifications, filters for bank/UPI senders,
/// and uses [GeminiTransactionParser] to extract transaction data.
class NotificationListenerServiceWrapper {
  final GeminiTransactionParser _parser;
  final String _userId;
  final _uuid = const Uuid();

  /// Stream of successfully parsed transactions
  Stream<TransactionEntity>? _transactionStream;

  NotificationListenerServiceWrapper({
    required GeminiTransactionParser parser,
    required String userId,
  }) : _parser = parser,
       _userId = userId;

  /// Returns true when the user has granted Notification Access permission
  Future<bool> hasPermission() async {
    return NotificationListenerService.isPermissionGranted();
  }

  /// Opens the system Notification Access settings screen
  Future<void> requestPermission() async {
    await NotificationListenerService.requestPermission();
  }

  /// Begins listening. Returns a stream that emits parsed [TransactionEntity]s.
  Stream<TransactionEntity> startListening() {
    _transactionStream ??= NotificationListenerService.notificationsStream
        .asyncExpand(_processEvent);
    return _transactionStream!;
  }

  Stream<TransactionEntity> _processEvent(
    ServiceNotificationEvent event,
  ) async* {
    final packageName = event.packageName ?? '';
    final title = event.title ?? '';
    final body = event.content ?? '';
    final text = '$title\n$body'.trim();

    appLogger.d('Notification received from: $packageName\nContent: $text');

    // Filter: only process if sender looks like a bank/UPI app
    if (!_isBankOrUpiNotification(packageName, title, body)) return;

    appLogger.i('Bank/UPI notification detected — sending to Gemini...');

    final parsed = await _parser.parse(text);

    if (!parsed.isTransactionMessage ||
        parsed.amount == null ||
        parsed.amount! <= 0) {
      appLogger.d('Not a transaction message, skipping.');
      return;
    }

    yield TransactionEntity(
      id: _uuid.v4(),
      userId: _userId,
      amount: parsed.amount!,
      type: parsed.type,
      category: parsed.category,
      merchant: parsed.merchant,
      accountLast4: parsed.accountLast4,
      bankName: parsed.bankName ?? _extractBankFromPackage(packageName),
      upiId: parsed.upiId,
      rawMessage: text,
      date: DateTime.now(),
      availableBalance: parsed.availableBalance,
    );
  }

  bool _isBankOrUpiNotification(String packageName, String title, String body) {
    // Check against known UPI/bank package names
    const knownPackages = [
      'com.google.android.apps.nbu.paisa.user', // Google Pay
      'net.one97.paytm', // Paytm
      'com.phonepe.app', // PhonePe
      'in.amazon.mShop.android.shopping', // Amazon Pay
      'com.whatsapp', // WhatsApp Pay
      'com.mobikwik_new', // MobiKwik
      'com.freecharge.android', // Freecharge
      'com.snapbizz.snapstore', // SnapPay
    ];

    if (knownPackages.any((pkg) => packageName.contains(pkg))) return true;

    // Also check if title/body has bank-related keywords
    final combined = '$title $body'.toLowerCase();
    return AppConstants.bankSenderKeywords.any(
      (kw) => combined.contains(kw.toLowerCase()),
    );
  }

  String? _extractBankFromPackage(String packageName) {
    const bankPackageMap = {
      'com.hdfcbank': 'HDFC Bank',
      'com.sbi': 'SBI',
      'com.icici': 'ICICI Bank',
      'com.axis': 'Axis Bank',
      'com.kotak': 'Kotak Bank',
      'com.yesbank': 'Yes Bank',
      'com.induslnd': 'IndusInd Bank',
    };
    for (final entry in bankPackageMap.entries) {
      if (packageName.contains(entry.key)) return entry.value;
    }
    return null;
  }
}

// ─── Riverpod Provider ────────────────────────────────────────────────────────

final notificationListenerServiceProvider =
    Provider.family<NotificationListenerServiceWrapper, String>((ref, userId) {
      const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
      return NotificationListenerServiceWrapper(
        parser: GeminiTransactionParser(apiKey: apiKey),
        userId: userId,
      );
    });

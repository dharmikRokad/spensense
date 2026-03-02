import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../utils/logger.dart';
import '../../../features/transactions/domain/entities/transaction_enums.dart';

/// Structured result from the LLM parser
class ParsedTransaction {
  final double? amount;
  final TransactionType type;
  final TransactionCategory category;
  final String merchant;
  final String? accountLast4;
  final String? bankName;
  final String? upiId;
  final double? availableBalance;
  final bool isTransactionMessage;

  const ParsedTransaction({
    this.amount,
    required this.type,
    required this.category,
    required this.merchant,
    this.accountLast4,
    this.bankName,
    this.upiId,
    this.availableBalance,
    required this.isTransactionMessage,
  });

  factory ParsedTransaction.notTransaction() {
    return const ParsedTransaction(
      type: TransactionType.unknown,
      category: TransactionCategory.other,
      merchant: 'Unknown',
      isTransactionMessage: false,
    );
  }
}

/// LLM-powered transaction parser using Gemini Flash.
/// Falls back to regex if the API call fails.
class GeminiTransactionParser {
  final GenerativeModel _model;

  GeminiTransactionParser({required String apiKey})
    : _model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0,
        ),
      );

  static const _systemPrompt = '''
You are a financial transaction parser for Indian banks and UPI apps.

Given a bank or UPI notification message, extract the transaction details and return a JSON object.

Rules:
- Only set "isTransactionMessage": true if the message is clearly a banking/UPI transaction alert
- amount: the transaction amount as a number (no currency symbols, no commas)
- type: "credit" (money received/deposited) or "debit" (money spent/sent/withdrawn) or "unknown"
- category: one of: food, shopping, transport, entertainment, utilities, health, education, travel, fuel, groceries, emi, investment, salary, transfer, cashback, recharge, subscription, other
- merchant: the merchant/sender/receiver name (clean, title-cased). Use "Unknown" if not found
- accountLast4: last 4 digits of account/card if mentioned, else null
- bankName: bank name if mentioned, else null
- upiId: UPI ID if mentioned, else null
- availableBalance: available/total balance after transaction if mentioned, else null

Return ONLY this JSON schema:
{
  "isTransactionMessage": boolean,
  "amount": number | null,
  "type": "credit" | "debit" | "unknown",
  "category": string,
  "merchant": string,
  "accountLast4": string | null,
  "bankName": string | null,
  "upiId": string | null,
  "availableBalance": number | null
}
''';

  Future<ParsedTransaction> parse(String notificationText) async {
    try {
      final response = await _model.generateContent([
        Content.text(
          '$_systemPrompt\n\nMessage to parse:\n"$notificationText"',
        ),
      ]);

      final rawJson = response.text;
      if (rawJson == null || rawJson.isEmpty) {
        appLogger.w('Gemini returned empty response, falling back to regex');
        return _regexFallback(notificationText);
      }

      final json = jsonDecode(rawJson) as Map<String, dynamic>;
      appLogger.d('Gemini parsed: $json');

      final isTransaction = json['isTransactionMessage'] as bool? ?? false;
      if (!isTransaction) return ParsedTransaction.notTransaction();

      return ParsedTransaction(
        isTransactionMessage: true,
        amount: (json['amount'] as num?)?.toDouble(),
        type: _parseType(json['type'] as String?),
        category: _parseCategory(json['category'] as String?),
        merchant: json['merchant'] as String? ?? 'Unknown',
        accountLast4: json['accountLast4'] as String?,
        bankName: json['bankName'] as String?,
        upiId: json['upiId'] as String?,
        availableBalance: (json['availableBalance'] as num?)?.toDouble(),
      );
    } catch (e) {
      appLogger.e('Gemini parse error, falling back to regex: $e');
      return _regexFallback(notificationText);
    }
  }

  // ─── Regex Fallback ───────────────────────────────────────────────────────

  ParsedTransaction _regexFallback(String text) {
    final lower = text.toLowerCase();

    // Determine transaction type
    TransactionType type = TransactionType.unknown;
    if (RegExp(
      r'\b(debited|debit|sent|paid|withdrawn|spent|dr\.?)\b',
    ).hasMatch(lower)) {
      type = TransactionType.debit;
    } else if (RegExp(
      r'\b(credited|credit|received|deposited|cr\.?|refund)\b',
    ).hasMatch(lower)) {
      type = TransactionType.credit;
    }

    // Extract amount (handles 1,23,456.78 and 1234.56 formats)
    double? amount;
    final amountMatch = RegExp(
      r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(text);
    if (amountMatch != null) {
      amount = double.tryParse(amountMatch.group(1)!.replaceAll(',', ''));
    }

    // Extract account last 4
    String? accountLast4;
    final accMatch = RegExp(
      r'(?:a/?c|account|card)[\s\w]*?(\d{4})\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (accMatch != null) accountLast4 = accMatch.group(1);

    // Extract available balance
    double? availableBalance;
    final balMatch = RegExp(
      r'(?:avl|available|bal\.?|balance)[:\s]*(?:rs\.?|inr|₹)?\s*([\d,]+(?:\.\d{1,2})?)',
      caseSensitive: false,
    ).firstMatch(text);
    if (balMatch != null) {
      availableBalance = double.tryParse(
        balMatch.group(1)!.replaceAll(',', ''),
      );
    }

    final isTransaction = amount != null && type != TransactionType.unknown;

    return ParsedTransaction(
      isTransactionMessage: isTransaction,
      amount: amount,
      type: type,
      category: _guessCategoryFromText(lower),
      merchant: _extractMerchant(text),
      accountLast4: accountLast4,
      availableBalance: availableBalance,
    );
  }

  String _extractMerchant(String text) {
    // Try to extract VPA/UPI merchant
    final upiMatch = RegExp(
      r'(?:to|from|at)\s+([\w.\-@]+@[\w.]+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (upiMatch != null) return upiMatch.group(1)!;

    // Extract name after "to" or "from"
    final nameMatch = RegExp(
      r'(?:to|from)\s+([A-Z][a-z]+(?: [A-Z][a-z]+)*)',
      caseSensitive: false,
    ).firstMatch(text);
    if (nameMatch != null) return nameMatch.group(1)!;

    return 'Unknown';
  }

  TransactionCategory _guessCategoryFromText(String lower) {
    if (RegExp(
      r'zomato|swiggy|food|restaurant|pizza|burger|cafe|dominos|kfc|mcdonalds',
    ).hasMatch(lower)) {
      return TransactionCategory.food;
    }
    if (RegExp(
      r'amazon|flipkart|myntra|ajio|nykaa|meesho|shop|store|mall|market',
    ).hasMatch(lower)) {
      return TransactionCategory.shopping;
    }
    if (RegExp(
      r'uber|ola|rapido|metro|bus|auto|cab|taxi|train|irctc',
    ).hasMatch(lower)) {
      return TransactionCategory.transport;
    }
    if (RegExp(
      r'netflix|prime|spotify|hotstar|zee5|sony|youtube|game|cinema|pvr',
    ).hasMatch(lower)) {
      return TransactionCategory.entertainment;
    }
    if (RegExp(
      r'petrol|diesel|fuel|pump|hp|bharat|ioc|indian oil',
    ).hasMatch(lower)) {
      return TransactionCategory.fuel;
    }
    if (RegExp(
      r'electricity|water|gas|broadband|internet|bsnl|airtel|jio|vi|vodafone',
    ).hasMatch(lower)) {
      return TransactionCategory.utilities;
    }
    if (RegExp(
      r'hospital|doctor|clinic|medicine|pharmacy|apollo|medical',
    ).hasMatch(lower)) {
      return TransactionCategory.health;
    }
    if (RegExp(
      r'emi|loan|equated|monthly|installment|hdfc loan|icici loan|sbi loan',
    ).hasMatch(lower)) {
      return TransactionCategory.emi;
    }
    if (RegExp(r'salary|payroll|ctc|wage|income').hasMatch(lower)) {
      return TransactionCategory.salary;
    }
    if (RegExp(r'recharge|prepaid|mobile|topup').hasMatch(lower)) {
      return TransactionCategory.recharge;
    }
    if (RegExp(
      r'bigbasket|dmart|grocer|vegetables|fruits|supermart',
    ).hasMatch(lower)) {
      return TransactionCategory.groceries;
    }
    if (RegExp(r'cashback|reward|bonus|offer').hasMatch(lower)) {
      return TransactionCategory.cashback;
    }
    if (RegExp(r'transfer|neft|imps|rtgs|upi').hasMatch(lower)) {
      return TransactionCategory.transfer;
    }
    return TransactionCategory.other;
  }

  TransactionType _parseType(String? raw) {
    return switch (raw?.toLowerCase()) {
      'credit' => TransactionType.credit,
      'debit' => TransactionType.debit,
      _ => TransactionType.unknown,
    };
  }

  TransactionCategory _parseCategory(String? raw) {
    if (raw == null) return TransactionCategory.other;
    try {
      return TransactionCategory.values.byName(raw.toLowerCase());
    } catch (_) {
      return TransactionCategory.other;
    }
  }
}

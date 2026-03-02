import 'package:equatable/equatable.dart';
import 'transaction_enums.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final String merchant;
  final String? accountLast4;
  final String? bankName;
  final String? upiId;
  final String rawMessage;
  final String? note;
  final DateTime date;
  final bool isManual; // true if added/edited by user
  final double? availableBalance;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.merchant,
    this.accountLast4,
    this.bankName,
    this.upiId,
    required this.rawMessage,
    this.note,
    required this.date,
    this.isManual = false,
    this.availableBalance,
  });

  TransactionEntity copyWith({
    String? id,
    String? userId,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    String? merchant,
    String? accountLast4,
    String? bankName,
    String? upiId,
    String? rawMessage,
    String? note,
    DateTime? date,
    bool? isManual,
    double? availableBalance,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      merchant: merchant ?? this.merchant,
      accountLast4: accountLast4 ?? this.accountLast4,
      bankName: bankName ?? this.bankName,
      upiId: upiId ?? this.upiId,
      rawMessage: rawMessage ?? this.rawMessage,
      note: note ?? this.note,
      date: date ?? this.date,
      isManual: isManual ?? this.isManual,
      availableBalance: availableBalance ?? this.availableBalance,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    amount,
    type,
    category,
    merchant,
    accountLast4,
    bankName,
    upiId,
    rawMessage,
    note,
    date,
    isManual,
  ];
}

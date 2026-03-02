import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_enums.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.amount,
    required super.type,
    required super.category,
    required super.merchant,
    super.accountLast4,
    super.bankName,
    super.upiId,
    required super.rawMessage,
    super.note,
    required super.date,
    super.isManual,
    super.availableBalance,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: TransactionType.values.byName(json['type'] as String),
      category: TransactionCategory.values.byName(json['category'] as String),
      merchant: json['merchant'] as String? ?? 'Unknown',
      accountLast4: json['accountLast4'] as String?,
      bankName: json['bankName'] as String?,
      upiId: json['upiId'] as String?,
      rawMessage: json['rawMessage'] as String? ?? '',
      note: json['note'] as String?,
      date: (json['date'] as Timestamp).toDate(),
      isManual: json['isManual'] as bool? ?? false,
      availableBalance: (json['availableBalance'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.name,
      'category': category.name,
      'merchant': merchant,
      'accountLast4': accountLast4,
      'bankName': bankName,
      'upiId': upiId,
      'rawMessage': rawMessage,
      'note': note,
      'date': Timestamp.fromDate(date),
      'isManual': isManual,
      'availableBalance': availableBalance,
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      amount: entity.amount,
      type: entity.type,
      category: entity.category,
      merchant: entity.merchant,
      accountLast4: entity.accountLast4,
      bankName: entity.bankName,
      upiId: entity.upiId,
      rawMessage: entity.rawMessage,
      note: entity.note,
      date: entity.date,
      isManual: entity.isManual,
      availableBalance: entity.availableBalance,
    );
  }
}

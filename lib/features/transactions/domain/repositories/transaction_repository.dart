import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  /// Save a single transaction (from notification or manual)
  Future<Either<Failure, void>> saveTransaction(TransactionEntity transaction);

  /// Save multiple transactions (batch)
  Future<Either<Failure, void>> saveTransactions(
    List<TransactionEntity> transactions,
  );

  /// Fetch all transactions for user, ordered by date desc
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required String userId,
    DateTime? from,
    DateTime? to,
    int limit,
  });

  /// Update an existing transaction (manual edits)
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity transaction,
  );

  /// Delete a transaction
  Future<Either<Failure, void>> deleteTransaction(String transactionId);

  /// Real-time stream of transactions
  Stream<List<TransactionEntity>> watchTransactions({required String userId});
}

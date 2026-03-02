import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class SaveTransactionUseCase {
  final TransactionRepository repository;
  SaveTransactionUseCase(this.repository);

  Future<Either<Failure, void>> call(TransactionEntity transaction) {
    return repository.saveTransaction(transaction);
  }
}

class GetTransactionsUseCase {
  final TransactionRepository repository;
  GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<TransactionEntity>>> call({
    required String userId,
    DateTime? from,
    DateTime? to,
    int limit = 100,
  }) {
    return repository.getTransactions(
      userId: userId,
      from: from,
      to: to,
      limit: limit,
    );
  }
}

class UpdateTransactionUseCase {
  final TransactionRepository repository;
  UpdateTransactionUseCase(this.repository);

  Future<Either<Failure, void>> call(TransactionEntity transaction) {
    return repository.updateTransaction(transaction);
  }
}

class DeleteTransactionUseCase {
  final TransactionRepository repository;
  DeleteTransactionUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) {
    return repository.deleteTransaction(id);
  }
}

class WatchTransactionsUseCase {
  final TransactionRepository repository;
  WatchTransactionsUseCase(this.repository);

  Stream<List<TransactionEntity>> call(String userId) {
    return repository.watchTransactions(userId: userId);
  }
}

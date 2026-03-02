import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepositoryImpl({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.transactionsCollection);

  @override
  Future<Either<Failure, void>> saveTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _collection.doc(model.id).set(model.toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveTransactions(
    List<TransactionEntity> transactions,
  ) async {
    try {
      final batch = _firestore.batch();
      for (final tx in transactions) {
        final model = TransactionModel.fromEntity(tx);
        batch.set(_collection.doc(model.id), model.toJson());
      }
      await batch.commit();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions({
    required String userId,
    DateTime? from,
    DateTime? to,
    int limit = 100,
  }) async {
    try {
      var query = _collection
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true);

      if (from != null) {
        query = query.where(
          'date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(from),
        );
      }
      if (to != null) {
        query = query.where(
          'date',
          isLessThanOrEqualTo: Timestamp.fromDate(to),
        );
      }

      final snapshot = await query.limit(limit).get();
      final transactions = snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();

      return Right(transactions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(
    TransactionEntity transaction,
  ) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await _collection.doc(model.id).update(model.toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId) async {
    try {
      await _collection.doc(transactionId).delete();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<TransactionEntity>> watchTransactions({required String userId}) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TransactionModel.fromJson(doc.data()))
              .toList(),
        );
  }
}

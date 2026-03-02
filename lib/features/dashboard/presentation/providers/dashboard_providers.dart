import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/entities/transaction_enums.dart';

class DashboardSummary {
  final double totalBalance;
  final double monthlyIncome;
  final double monthlyExpenses;

  const DashboardSummary({
    this.totalBalance = 0.0,
    this.monthlyIncome = 0.0,
    this.monthlyExpenses = 0.0,
  });
}

/// Watches all transactions for the current user and computes the summary.
final dashboardSummaryProvider = Provider<AsyncValue<DashboardSummary>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const AsyncValue.data(DashboardSummary());

  final transactionsStream = ref
      .watch(watchTransactionsUseCaseProvider)
      .call(user.uid);

  return ref.watch(StreamProvider((_) => transactionsStream)).whenData((
    transactions,
  ) {
    double balance = 0.0;
    double income = 0.0;
    double expense = 0.0;

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    for (final tx in transactions) {
      if (tx.type == TransactionType.credit) {
        balance += tx.amount;
        if (tx.date.isAfter(firstDayOfMonth)) {
          income += tx.amount;
        }
      } else if (tx.type == TransactionType.debit) {
        balance -= tx.amount;
        if (tx.date.isAfter(firstDayOfMonth)) {
          expense += tx.amount;
        }
      }
    }

    return DashboardSummary(
      totalBalance: balance,
      monthlyIncome: income,
      monthlyExpenses: expense,
    );
  });
});

/// Watches the 5 most recent transactions.
final recentTransactionsProvider =
    Provider<AsyncValue<List<TransactionEntity>>>((ref) {
      final user = ref.watch(currentUserProvider);
      if (user == null) return const AsyncValue.data([]);

      final transactionsStream = ref
          .watch(watchTransactionsUseCaseProvider)
          .call(user.uid);

      return ref.watch(StreamProvider((_) => transactionsStream)).whenData((
        transactions,
      ) {
        // Already sorted by repository by date desc
        return transactions.take(5).toList();
      });
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';
import '../../../transactions/domain/entities/transaction_enums.dart';

class CategorySpending {
  final TransactionCategory category;
  final double amount;
  final double percentage;

  CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

/// Computes category-wise spending breakdown for the current month.
final categorySpendingProvider = Provider<AsyncValue<List<CategorySpending>>>((
  ref,
) {
  final user = ref.watch(currentUserProvider);

  if (user == null) return const AsyncValue.data([]);

  // We need the full list of transactions for the current month to group by category
  final transactionsStream = ref
      .watch(watchTransactionsUseCaseProvider)
      .call(user.uid);

  return ref.watch(StreamProvider((_) => transactionsStream)).whenData((
    transactions,
  ) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);

    final Map<TransactionCategory, double> categoryTotals = {};
    double totalMonthlyExpense = 0;

    for (final tx in transactions) {
      if (tx.type == TransactionType.debit &&
          tx.date.isAfter(firstDayOfMonth)) {
        categoryTotals[tx.category] =
            (categoryTotals[tx.category] ?? 0) + tx.amount;
        totalMonthlyExpense += tx.amount;
      }
    }

    if (totalMonthlyExpense == 0) return [];

    final spendingList = categoryTotals.entries.map((entry) {
      return CategorySpending(
        category: entry.key,
        amount: entry.value,
        percentage: (entry.value / totalMonthlyExpense) * 100,
      );
    }).toList();

    // Sort by amount descending
    spendingList.sort((a, b) => b.amount.compareTo(a.amount));

    return spendingList;
  });
});

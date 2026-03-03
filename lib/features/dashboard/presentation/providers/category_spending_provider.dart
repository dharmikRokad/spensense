import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../transactions/domain/entities/transaction_enums.dart';
import '../providers/dashboard_providers.dart';

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
/// Reuses [_dashboardTransactionsProvider] to avoid creating a second stream.
final categorySpendingProvider = Provider<AsyncValue<List<CategorySpending>>>((
  ref,
) {
  // Re-use the same underlying stream that the dashboard already watches —
  // no need for a separate Firestore listener.
  return ref.watch(dashboardTransactionsProvider).whenData((transactions) {
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

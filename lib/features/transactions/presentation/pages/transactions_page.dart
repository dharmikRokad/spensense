import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_enums.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class TransactionsPage extends ConsumerWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final transactionsStream = ref
        .watch(watchTransactionsUseCaseProvider)
        .call(user.uid);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {
              // TODO: Implement filters
            },
          ),
        ],
      ),
      body: StreamBuilder<List<TransactionEntity>>(
        stream: transactionsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return const _EmptyTransactionsView();
          }

          final groupedTransactions = _groupTransactionsByDate(transactions);

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: groupedTransactions.length,
            itemBuilder: (context, index) {
              final group = groupedTransactions[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DateHeader(date: group.date, colors: colors),
                  ...group.items.map(
                    (tx) =>
                        _TransactionListRow(transaction: tx, colors: colors),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  List<_TransactionGroup> _groupTransactionsByDate(
    List<TransactionEntity> transactions,
  ) {
    final Map<DateTime, List<TransactionEntity>> groups = {};

    for (final tx in transactions) {
      final date = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (!groups.containsKey(date)) {
        groups[date] = [];
      }
      groups[date]!.add(tx);
    }

    final sortedDates = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return sortedDates
        .map((date) => _TransactionGroup(date: date, items: groups[date]!))
        .toList();
  }
}

class _TransactionGroup {
  final DateTime date;
  final List<TransactionEntity> items;

  _TransactionGroup({required this.date, required this.items});
}

class _DateHeader extends StatelessWidget {
  final DateTime date;
  final AppColors colors;

  const _DateHeader({required this.date, required this.colors});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    String label;
    if (date == today) {
      label = 'Today';
    } else if (date == yesterday) {
      label = 'Yesterday';
    } else {
      label = DateFormat('MMM dd, yyyy').format(date);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: colors.surface2,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.textSub,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _TransactionListRow extends StatelessWidget {
  final TransactionEntity transaction;
  final AppColors colors;

  const _TransactionListRow({required this.transaction, required this.colors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.debit;

    return InkWell(
      onTap: () => context.push('/transactions/edit/${transaction.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(bottom: BorderSide(color: colors.border)),
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  transaction.category.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Merchant & Category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.merchant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.category.displayName,
                    style: theme.textTheme.labelMedium,
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${isExpense ? '−' : '+'}${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(transaction.amount)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: isExpense ? colors.red : colors.accent,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyTransactionsView extends StatelessWidget {
  const _EmptyTransactionsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_rounded, size: 64, color: colors.textDim),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: theme.textTheme.titleMedium?.copyWith(color: colors.textSub),
          ),
          const SizedBox(height: 8),
          const Text('Your financial journey starts with the first entry.'),
        ],
      ),
    );
  }
}

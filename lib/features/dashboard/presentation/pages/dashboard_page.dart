import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';
import '../../../transactions/domain/entities/transaction_enums.dart';
import '../providers/category_spending_provider.dart';
import '../providers/dashboard_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final recentAsync = ref.watch(recentTransactionsProvider);
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ─── Header / Balance Hero ───────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Balance',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colors.textSub,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    summaryAsync.when(
                      data: (summary) => Text(
                        NumberFormat.currency(
                          symbol: '₹',
                          decimalDigits: 0,
                        ).format(summary.totalBalance),
                        style: theme.textTheme.displayLarge,
                      ),
                      loading: () =>
                          _LoadingPlaceholder(width: 200, height: 40),
                      error: (_, _) => const Text(
                        '₹0',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Income & Expense Pills ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: summaryAsync.when(
                  data: (summary) => Row(
                    children: [
                      Expanded(
                        child: _StatPill(
                          label: 'Income',
                          amount: summary.monthlyIncome,
                          isIncome: true,
                          colors: colors,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatPill(
                          label: 'Expenses',
                          amount: summary.monthlyExpenses,
                          isIncome: false,
                          colors: colors,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Row(
                    children: [
                      Expanded(child: _LoadingPlaceholder(height: 80)),
                      SizedBox(width: 12),
                      Expanded(child: _LoadingPlaceholder(height: 80)),
                    ],
                  ),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ),
            ),

            // ─── Category Breakdown Chart ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: _CategoryBreakdownChart(),
              ),
            ),

            // ─── Recent Transactions Section Header ──────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Transactions',
                      style: theme.textTheme.titleMedium,
                    ),
                    TextButton(
                      onPressed: () => context.go('/transactions'),
                      child: Text(
                        'See All',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Recent Transactions List ────────────────────────────
            recentAsync.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: _EmptyTransactionsView(),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final tx = transactions[index];
                      final isLast = index == transactions.length - 1;
                      return _TransactionRow(
                        transaction: tx,
                        colors: colors,
                        isLast: isLast,
                      );
                    }, childCount: transactions.length),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: _LoadingPlaceholder(height: 70),
                    ),
                    childCount: 3,
                  ),
                ),
              ),
              error: (err, _) =>
                  SliverToBoxAdapter(child: Center(child: Text('Error: $err'))),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transactions/add'),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final double amount;
  final bool isIncome;
  final AppColors colors;

  const _StatPill({
    required this.label,
    required this.amount,
    required this.isIncome,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = isIncome ? colors.accentSoft : colors.redSoft;
    final textColor = isIncome ? colors.accent : colors.red;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: textColor,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textColor.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(amount),
            style: theme.textTheme.titleMedium?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final TransactionEntity transaction;
  final AppColors colors;
  final bool isLast;

  const _TransactionRow({
    required this.transaction,
    required this.colors,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == TransactionType.debit;

    return InkWell(
      onTap: () => context.push('/transactions/edit/${transaction.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            // Category Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  transaction.category.emoji,
                  style: const TextStyle(fontSize: 20),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isExpense ? '−' : '+'}${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(transaction.amount)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isExpense ? colors.red : colors.accent,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMM dd').format(transaction.date),
                  style: theme.textTheme.labelMedium?.copyWith(fontSize: 10),
                ),
              ],
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surface2,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                size: 40,
                color: colors.textDim,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.textSub,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your detected transactions will appear here.',
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBreakdownChart extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spendingAsync = ref.watch(categorySpendingProvider);
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return spendingAsync.when(
      data: (spending) {
        if (spending.isEmpty) return const SizedBox.shrink();

        // Take top 5 for the donut, rest in "Others"
        final top5 = spending.take(5).toList();
        final others = spending
            .skip(5)
            .fold(0.0, (sum, item) => sum + item.amount);

        if (others > 0) {
          top5.add(
            CategorySpending(
              category: TransactionCategory.other,
              amount: others,
              percentage: 0, // Not strictly needed for logic here
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spending Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  SizedBox(
                    height: 140,
                    width: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 4,
                        centerSpaceRadius: 40,
                        sections: top5.map((s) {
                          return PieChartSectionData(
                            color: s.category.color,
                            value: s.amount,
                            title: '',
                            radius: 18,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: top5
                          .map((s) => _LegendItem(spending: s, colors: colors))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const _LoadingPlaceholder(height: 180),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final CategorySpending spending;
  final AppColors colors;

  const _LegendItem({required this.spending, required this.colors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: spending.category.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              spending.category.displayName,
              style: theme.textTheme.labelMedium?.copyWith(fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            NumberFormat.compactCurrency(
              symbol: '₹',
              decimalDigits: 0,
            ).format(spending.amount),
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.textSub,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  final double width;
  final double height;

  const _LoadingPlaceholder({
    this.width = double.infinity,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

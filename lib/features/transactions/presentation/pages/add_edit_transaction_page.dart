import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/transaction_enums.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../auth/presentation/providers/auth_notifier.dart';

class AddEditTransactionPage extends ConsumerStatefulWidget {
  final String? transactionId;
  const AddEditTransactionPage({super.key, this.transactionId});

  @override
  ConsumerState<AddEditTransactionPage> createState() =>
      _AddEditTransactionPageState();
}

class _AddEditTransactionPageState
    extends ConsumerState<AddEditTransactionPage> {
  final _merchantController = TextEditingController();
  final _noteController = TextEditingController();

  String _amountStr = '0';
  TransactionType _type = TransactionType.debit;
  TransactionCategory _category = TransactionCategory.shopping;
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _loadTransaction();
    }
  }

  Future<void> _loadTransaction() async {
    setState(() => _isLoading = true);
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final result = await ref
        .read(getTransactionsUseCaseProvider)
        .call(userId: user.uid);

    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (transactions) {
        final tx = transactions.firstWhere((t) => t.id == widget.transactionId);
        setState(() {
          _amountStr = tx.amount.toInt().toString();
          _type = tx.type;
          _category = tx.category;
          _merchantController.text = tx.merchant;
          _noteController.text = tx.note ?? '';
          _date = tx.date;
        });
      },
    );
    setState(() => _isLoading = false);
  }

  void _onNumberPressed(String value) {
    setState(() {
      if (_amountStr == '0') {
        _amountStr = value;
      } else {
        _amountStr += value;
      }
    });
  }

  void _onBackspace() {
    setState(() {
      if (_amountStr.length <= 1) {
        _amountStr = '0';
      } else {
        _amountStr = _amountStr.substring(0, _amountStr.length - 1);
      }
    });
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountStr) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_merchantController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a merchant name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final transaction = TransactionEntity(
      id: widget.transactionId ?? const Uuid().v4(),
      userId: user.uid,
      amount: amount,
      type: _type,
      category: _category,
      merchant: _merchantController.text,
      date: _date,
      note: _noteController.text,
      rawMessage: 'Manual Entry',
      isManual: true,
    );

    final result = widget.transactionId == null
        ? await ref.read(saveTransactionUseCaseProvider).call(transaction)
        : await ref.read(updateTransactionUseCaseProvider).call(transaction);

    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => context.pop(),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    if (_isLoading && widget.transactionId != null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: Text(
          widget.transactionId == null ? 'Add Transaction' : 'Edit Transaction',
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // ─── Amount Display ───────────────────────────────
                  Text(
                    '₹$_amountStr',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: _type == TransactionType.debit
                          ? colors.red
                          : colors.accent,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ─── Type Toggle ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TypeChip(
                        label: 'Expense',
                        isSelected: _type == TransactionType.debit,
                        selectedColor: colors.red,
                        onTap: () =>
                            setState(() => _type = TransactionType.debit),
                      ),
                      const SizedBox(width: 12),
                      _TypeChip(
                        label: 'Income',
                        isSelected: _type == TransactionType.credit,
                        selectedColor: colors.accent,
                        onTap: () =>
                            setState(() => _type = TransactionType.credit),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ─── Form Fields ──────────────────────────────────
                  TextField(
                    controller: _merchantController,
                    decoration: const InputDecoration(
                      labelText: 'Merchant',
                      hintText: 'e.g. Starbucks, Amazon',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category Selector
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: TransactionCategory.values.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = TransactionCategory.values[index];
                        final isSelected = _category == cat;
                        return FilterChip(
                          label: Text(cat.displayName),
                          avatar: Text(cat.emoji),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _category = cat),
                          backgroundColor: colors.surface,
                          selectedColor: colors.accentSoft,
                          checkmarkColor: colors.accent,
                          labelStyle: theme.textTheme.labelMedium?.copyWith(
                            color: isSelected ? colors.accent : colors.textSub,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? colors.accent : colors.border,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (Optional)',
                      hintText: 'What was this for?',
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ─── Numeric Keypad ───────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Column(
              children: [
                _buildKeypadRow(['1', '2', '3']),
                _buildKeypadRow(['4', '5', '6']),
                _buildKeypadRow(['7', '8', '9']),
                _buildKeypadRow(['00', '0', 'delete']),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Transaction'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        if (key == 'delete') {
          return Expanded(
            child: InkWell(
              onTap: _onBackspace,
              child: const SizedBox(
                height: 54,
                child: Center(child: Icon(Icons.backspace_outlined, size: 20)),
              ),
            ),
          );
        }
        return Expanded(
          child: InkWell(
            onTap: () => _onNumberPressed(key),
            child: SizedBox(
              height: 54,
              child: Center(
                child: Text(
                  key,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? selectedColor : colors.border),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : colors.textSub,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

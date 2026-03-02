import 'package:flutter/material.dart';

class AddEditTransactionPage extends StatelessWidget {
  final String? transactionId;
  const AddEditTransactionPage({super.key, this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          transactionId == null ? 'Add Transaction' : 'Edit Transaction',
        ),
      ),
      body: const Center(child: Text('Add / Edit Transaction — Phase 5')),
    );
  }
}

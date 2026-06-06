import 'package:flutter/material.dart';
import 'package:minimobile/models/transaction_model.dart';
import 'package:minimobile/themes/app_theme.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == 'Pemasukan';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCredit
                    ? AppTheme.successColor.withOpacity(0.1)
                    : AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? AppTheme.successColor : AppTheme.errorColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.category,
                    style: AppTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.date,
                    style: AppTheme.bodySmall.copyWith(color: Colors.grey),
                  ),
                  if (transaction.relatedUser != null)
                    Text(
                      transaction.relatedUser!,
                      style: AppTheme.bodySmall.copyWith(color: Colors.grey),
                    ),
                ],
              ),
            ),
            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.amount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCredit ? AppTheme.successColor : AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.balanceAfter,
                  style: AppTheme.bodySmall.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
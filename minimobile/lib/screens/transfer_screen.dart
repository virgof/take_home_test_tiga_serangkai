import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:minimobile/providers/transaction_provider.dart';
import 'package:minimobile/providers/auth_provider.dart';
import 'package:minimobile/widgets/custom_button.dart';
import 'package:minimobile/widgets/custom_textfield.dart';
import 'package:minimobile/themes/app_theme.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      Fluttertoast.showToast(
        msg: 'Invalid amount',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    final transactionProvider = Provider.of<TransactionProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check self transfer
    if (_recipientController.text.trim() == authProvider.user?.email) {
      Fluttertoast.showToast(
        msg: 'Cannot transfer to yourself',
        backgroundColor: Colors.red,
      );
      setState(() => _isLoading = false);
      return;
    }

    // Check sufficient balance
    if (amount > (transactionProvider.balance?.raw ?? 0)) {
      Fluttertoast.showToast(
        msg: 'Insufficient balance',
        backgroundColor: Colors.red,
      );
      setState(() => _isLoading = false);
      return;
    }

    try {
      final success = await transactionProvider.transfer(
        recipientEmail: _recipientController.text.trim(),
        amount: amount,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (success) {
        Fluttertoast.showToast(
          msg: 'Transfer successful!',
          backgroundColor: Colors.green,
        );
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final currentBalance = transactionProvider.balance?.raw ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transactionProvider.balance?.formatted ?? 'Rp0',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Transfer Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _recipientController,
                      label: 'Recipient Email',
                      icon: Icons.person_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Recipient email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _amountController,
                      label: 'Amount',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Amount is required';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Amount must be greater than 0';
                        }
                        if (amount > currentBalance) {
                          return 'Insufficient balance';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description (Optional)',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Transfer Now',
                      onPressed: _handleTransfer,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Warning Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Transfer cannot be canceled. Please double-check the recipient email.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
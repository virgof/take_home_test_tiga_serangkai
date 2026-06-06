import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimobile/providers/transaction_provider.dart';
import 'package:minimobile/widgets/transaction_card.dart';
import 'package:minimobile/themes/app_theme.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  String _selectedType = '';
  String _selectedSort = 'Date';
  String _selectedOrder = 'Newest';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    String? type;
    if (_selectedType == 'Pemasukan') {
      type = 'credit';
    } else if (_selectedType == 'Pengeluaran') {
      type = 'debit';
    } else {
      type = null;
    }

    String sortBy = _selectedSort == 'Date' ? 'created_at' : 'amount';
    String sortOrder = _selectedOrder == 'Newest' ? 'desc' : 'asc';

    print('Loading transactions - Type: $type, SortBy: $sortBy, SortOrder: $sortOrder');

    await provider.fetchTransactions(
      type: type,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  Future<void> _refreshData() async {
    await _loadTransactions();
  }

  Future<void> _changePage(int page) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    String? type;
    if (_selectedType == 'Pemasukan') {
      type = 'credit';
    } else if (_selectedType == 'Pengeluaran') {
      type = 'debit';
    } else {
      type = null;
    }

    String sortBy = _selectedSort == 'Date' ? 'created_at' : 'amount';
    String sortOrder = _selectedOrder == 'Newest' ? 'desc' : 'asc';

    await provider.fetchTransactions(
      page: page,
      type: type,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        value: _selectedType.isEmpty ? 'All' : _selectedType,
                        items: const ['All', 'Pemasukan', 'Pengeluaran'],
                        label: 'Type',
                        onChanged: (value) {
                          setState(() {
                            if (value == 'All') {
                              _selectedType = '';
                            } else {
                              _selectedType = value!;
                            }
                          });
                          _loadTransactions();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDropdown(
                        value: _selectedSort,
                        items: const ['Date', 'Amount'],
                        label: 'Sort By',
                        onChanged: (value) {
                          setState(() => _selectedSort = value!);
                          _loadTransactions();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        value: _selectedOrder,
                        items: const ['Newest', 'Oldest'],
                        label: 'Order',
                        onChanged: (value) {
                          setState(() => _selectedOrder = value!);
                          _loadTransactions();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedType = '';     // Reset ke All
                            _selectedSort = 'Date';
                            _selectedOrder = 'Newest';
                          });
                          _loadTransactions();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Reset Filters'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshData,
              child: transactionProvider.isLoading && transactionProvider.transactions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : transactionProvider.transactions.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No transactions found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: transactionProvider.transactions.length,
                itemBuilder: (context, index) {
                  return TransactionCard(
                    transaction: transactionProvider.transactions[index],
                  );
                },
              ),
            ),
          ),

          // Pagination
          if (transactionProvider.totalPages > 1)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: transactionProvider.currentPage > 1
                        ? () => _changePage(transactionProvider.currentPage - 1)
                        : null,
                  ),
                  Text(
                    'Page ${transactionProvider.currentPage} of ${transactionProvider.totalPages}',
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: transactionProvider.currentPage < transactionProvider.totalPages
                        ? () => _changePage(transactionProvider.currentPage + 1)
                        : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required String label,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
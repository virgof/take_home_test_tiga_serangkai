import 'package:flutter/material.dart';
import 'package:minimobile/services/api_service.dart';
import 'package:minimobile/models/transaction_model.dart';
import 'package:minimobile/models/user_model.dart';
import 'dart:convert';

class TransactionProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  Balance? _balance;
  Statistics? _statistics;
  List<Transaction> _transactions = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _total = 0;
  bool _isLoading = false;
  String? _error;

  Balance? get balance => _balance;
  Statistics? get statistics => _statistics;
  List<Transaction> get transactions => _transactions;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get total => _total;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get('dashboard');
      print('Dashboard Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Dashboard Data: $data');

        if (data['status'] == 'success') {
          final dashboardData = data['data'];
          _balance = Balance.fromJson(dashboardData['balance']);
          _statistics = Statistics.fromJson(dashboardData['statistics']);
        }
      } else {
        _error = 'Failed to load dashboard';
        print('Dashboard error: ${response.body}');
      }
    } catch (e) {
      _error = 'Network error: $e';
      print('Dashboard exception: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> transfer({
    required String recipientEmail,
    required double amount,
    String? description,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post('transfer', {
        'recipient_email': recipientEmail,
        'amount': amount,
        'description': description,
      });

      print('Transfer Response: ${response.statusCode}');
      print('Transfer Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        await fetchDashboard();
        await fetchTransactions();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'] ?? 'Transfer failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchTransactions({
    int page = 1,
    int perPage = 10,
    String? type,
    String? sortBy = 'created_at',
    String? sortOrder = 'desc',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String endpoint = 'transactions?page=$page&per_page=$perPage';

      if (sortBy != null) {
        endpoint += '&sort_by=$sortBy';
      }
      if (sortOrder != null) {
        endpoint += '&sort_order=$sortOrder';
      }

      if (type != null && type.isNotEmpty) {
        endpoint += '&type=$type';
      }

      print('Fetching transactions URL: $endpoint');

      final response = await _api.get(endpoint);
      print('Transactions Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Raw Response: $data');

        if (data['status'] == 'success') {
          try {
            final transactionResponse = TransactionResponse.fromJson(data['data']);
            _transactions = transactionResponse.data;
            _currentPage = transactionResponse.currentPage;
            _totalPages = transactionResponse.lastPage;
            _total = transactionResponse.total;

            print('Loaded ${_transactions.length} transactions');
            print('Current Page: $_currentPage, Total Pages: $_totalPages');

            if (_transactions.isNotEmpty) {
              print('First transaction: ${_transactions.first.id} - ${_transactions.first.amount}');
            }
          } catch (e) {
            print('Error parsing transactions: $e');
            _error = 'Error parsing data: $e';
          }
        } else {
          _error = data['message'] ?? 'Failed to load transactions';
          print('API Error: ${data['message']}');
        }
      } else {
        _error = 'Failed to load transactions (HTTP ${response.statusCode})';
        print('HTTP Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      _error = 'Network error: $e';
      print('Network Exception: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void reset() {
    _balance = null;
    _statistics = null;
    _transactions = [];
    _currentPage = 1;
    _totalPages = 1;
    _total = 0;
    _error = null;
    notifyListeners();
  }
}
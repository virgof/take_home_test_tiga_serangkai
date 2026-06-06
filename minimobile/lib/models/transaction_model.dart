class Transaction {
  final int id;
  final String date;
  final String type;
  final String category;
  final String amount;
  final double amountRaw;
  final String balanceBefore;
  final String balanceAfter;
  final String? description;
  final String referenceId;
  final String? relatedUser;

  Transaction({
    required this.id,
    required this.date,
    required this.type,
    required this.category,
    required this.amount,
    required this.amountRaw,
    required this.balanceBefore,
    required this.balanceAfter,
    this.description,
    required this.referenceId,
    this.relatedUser,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    print('Parsing transaction: $json');

    return Transaction(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      amount: json['amount'] ?? 'Rp0',
      amountRaw: json['amount_raw'] is double
          ? json['amount_raw']
          : double.parse(json['amount_raw'].toString()),
      balanceBefore: json['balance_before'] ?? 'Rp0',
      balanceAfter: json['balance_after'] ?? 'Rp0',
      description: json['description'],
      referenceId: json['reference_id'] ?? '',
      relatedUser: json['related_user'],
    );
  }
}

class TransactionResponse {
  final int currentPage;
  final List<Transaction> data;
  final int total;
  final int perPage;
  final int lastPage;
  final int? from;
  final int? to;

  TransactionResponse({
    required this.currentPage,
    required this.data,
    required this.total,
    required this.perPage,
    required this.lastPage,
    this.from,
    this.to,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    print('TransactionResponse fromJson: $json');

    return TransactionResponse(
      currentPage: json['current_page'] is int
          ? json['current_page']
          : int.parse(json['current_page'].toString()),
      data: (json['data'] as List)
          .map((item) => Transaction.fromJson(item))
          .toList(),
      total: json['total'] is int
          ? json['total']
          : int.parse(json['total'].toString()),
      perPage: json['per_page'] is int
          ? json['per_page']
          : int.parse(json['per_page'].toString()),
      lastPage: json['last_page'] is int
          ? json['last_page']
          : int.parse(json['last_page'].toString()),
      from: json['from'] != null
          ? (json['from'] is int ? json['from'] : int.parse(json['from'].toString()))
          : null,
      to: json['to'] != null
          ? (json['to'] is int ? json['to'] : int.parse(json['to'].toString()))
          : null,
    );
  }
}
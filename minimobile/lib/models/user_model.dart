class User {
  final int id;
  final String name;
  final String email;
  final String? createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt,
    };
  }
}

class Balance {
  final String current;
  final double raw;
  final String formatted;

  Balance({
    required this.current,
    required this.raw,
    required this.formatted,
  });

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      current: json['current'],
      raw: double.parse(json['raw'].toString()),
      formatted: json['formatted'],
    );
  }
}

class Statistics {
  final int totalTransactions;
  final String totalSent;
  final String totalReceived;
  final String memberSince;

  Statistics({
    required this.totalTransactions,
    required this.totalSent,
    required this.totalReceived,
    required this.memberSince,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalTransactions: json['total_transactions'],
      totalSent: json['total_sent'],
      totalReceived: json['total_received'],
      memberSince: json['member_since'],
    );
  }
}
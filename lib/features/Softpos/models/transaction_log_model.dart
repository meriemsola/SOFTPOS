
class TransactionLog {
  final String pan;
  final String expiration;
  final String atc;
  final String result;
  final DateTime timestamp;
  final double amount;
  final String dateTime;
  final String status;
  final bool isOnline;

  TransactionLog({
    required this.pan,
    required this.expiration,
    required this.atc,
    required this.result,
    required this.timestamp,
    required this.amount,
    required this.dateTime,
    required this.status,
    required this.isOnline,
  });

  factory TransactionLog.fromMap(Map<String, dynamic> map) {
    return TransactionLog(
      pan: map['pan'] as String,
      expiration: map['expiration'] as String,
      atc: map['atc'] as String,
      result: map['result'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      amount: (map['amount'] as num).toDouble(),
      dateTime: map['dateTime'] as String,
      status: map['status'] as String,
      isOnline: map['isOnline'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pan': pan,
      'expiration': expiration,
      'atc': atc,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
      'amount': amount,
      'dateTime': dateTime,
      'status': status,
      'isOnline': isOnline,
    };
  }

  @override
  String toString() {
    return 'TransactionLog(pan: $pan, amount: $amount, status: $status)';
  }
}
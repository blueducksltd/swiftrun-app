class Transaction {
  int? id;
  String? domain;
  String? status;
  String? reference;
  String? receiptNumber;
  int? amount;
  String? message;
  String? gatewayResponse;
  DateTime? paidAt;
  DateTime? createdAt;
  String? channel;
  String? currency;
  int? fees;

  Transaction({
    this.id,
    this.domain,
    this.status,
    this.reference,
    this.receiptNumber,
    this.amount,
    this.message,
    this.gatewayResponse,
    this.paidAt,
    this.createdAt,
    this.channel,
    this.currency,
    this.fees,
  });

  // Factory constructor to create a Transaction object from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      domain: json['domain'],
      status: json['status'],
      reference: json['reference'],
      receiptNumber: json['receipt_number'] ?? '',
      amount: json['amount'],
      message: json['message'] ?? '',
      gatewayResponse: json['gateway_response'],
      paidAt: DateTime.parse(json['paidAt']),
      createdAt: DateTime.parse(json['createdAt']),
      channel: json['channel'],
      currency: json['currency'],
      fees: json['fees'],
    );
  }

  // Method to convert Transaction object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'domain': domain,
      'status': status,
      'reference': reference,
      'receipt_number': receiptNumber,
      'amount': amount,
      'message': message,
      'gateway_response': gatewayResponse,
      'paidAt': paidAt!.toIso8601String(),
      'createdAt': createdAt!.toIso8601String(),
      'channel': channel,
      'currency': currency,
      'fees': fees,
    };
  }
}

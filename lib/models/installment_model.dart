class Installment {
  final String id;
  final double amountPaid;
  final DateTime datePaid;

  Installment({
    required this.id,
    required this.amountPaid,
    required this.datePaid,
  });

  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(
      id: json['id'] as String,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ??
          0.0, // 🔹 Jika null, gunakan 0.0
      datePaid: DateTime.parse(json['date_paid']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount_paid': amountPaid,
      'date_paid': datePaid.toIso8601String(),
    };
  }
}

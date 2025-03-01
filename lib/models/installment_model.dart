// Model untuk Cicilan (Installment)
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
      id: json['id'],
      amountPaid: (json['amountPaid'] as num).toDouble(),
      datePaid: DateTime.parse(json['datePaid']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amountPaid': amountPaid,
      'datePaid': datePaid.toIso8601String(),
    };
  }
}

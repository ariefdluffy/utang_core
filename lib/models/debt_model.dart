import 'package:utang_core/models/installment_model.dart';

class Debt {
  final String id;
  final String userId;
  final String title;

  final double amount;
  final List<Installment> installments;
  final DateTime createdAt;
  final bool isPaid;

  Debt(
      {required this.id,
      required this.userId,
      required this.title,
      required this.amount,
      required this.installments,
      required this.createdAt,
      required this.isPaid});

  double get totalPaid =>
      installments.fold(0, (sum, item) => sum + item.amountPaid);

  // 🔹 Perbaikan: Tangani `installments` yang mungkin null
  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      // installments: (json['installments'] as List<dynamic>)
      //     .map((e) => Installment.fromJson(e))
      //     .toList()
      installments: (json['installments'] != null)
          ? (json['installments'] as List<dynamic>)
              .map((e) => Installment.fromJson(e))
              .toList()
          : [], // 🔹 Gunakan list kosong jika installments null
      createdAt: DateTime.parse(json['created_at']),
      isPaid: json['is_paid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'installments': installments.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'is_paid': isPaid,
    };
  }
}

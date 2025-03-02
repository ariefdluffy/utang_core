import 'package:utang_core/models/installment_model.dart';

class Debt {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final List<Installment> installments;

  Debt({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.installments,
  });

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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'installments': installments.map((e) => e.toJson()).toList(),
    };
  }
}

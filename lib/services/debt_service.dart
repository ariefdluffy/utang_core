import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utang_core/models/debt_model.dart';

class DebtService {
  static final supabase = Supabase.instance.client;

  static Future<List<Debt>> getDebts(String userId) async {
    final response =
        await supabase.from('debts').select().eq('user_id', userId);
    return response.map((e) => Debt.fromJson(e)).toList();
  }

  static Future<void> addDebt(Debt debt) async {
    try {
      print("🔹 Data yang dikirim: ${debt.toJson()}"); // Debugging

      final response = await supabase.from('debts').insert(debt.toJson());

      if (response.error != null) {
        print("❌ Error: ${response.toString()}");
      } else {
        print("✅ Hutang berhasil disimpan!");
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
  }

  static Future<void> updateDebt(Debt debt) async {
    await supabase.from('debts').update(debt.toJson()).eq('id', debt.id);
  }
}

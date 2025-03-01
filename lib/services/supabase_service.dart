import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utang_core/models/debt_model.dart';
import 'package:utang_core/models/installment_model.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;

  SupabaseService._internal();

  final supabase = Supabase.instance.client;

  Future<User?> signUp(String email, String password) async {
    final response =
        await supabase.auth.signUp(email: email, password: password);
    return response.user;
  }

  Future<User?> signIn(String email, String password) async {
    final response = await supabase.auth
        .signInWithPassword(email: email, password: password);
    return response.user;
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? get currentUser => supabase.auth.currentUser;

  Future<void> addDebt(Debt debt) async {
    try {
      final response = await supabase.from('debts').insert({
        'id': debt.id,
        'user_id': debt.userId,
        'title': debt.title,
        'amount': debt.amount,
        'created_at': DateTime.now().toIso8601String(),
      });

      print("✅ Hutang berhasil disimpan!");
    } catch (e) {
      print("❌ Error saat menyimpan hutang ke Supabase: $e");
      throw e;
    }
  }

  Future<List<Debt>> getDebts(String userId) async {
    try {
      final List<dynamic> response = await supabase
          .from('debts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      print(response);
      return response.map<Debt>((debt) => Debt.fromJson(debt)).toList();
    } catch (e) {
      print("❌ Error mengambil hutang dari Supabase: $e");
      return [];
    }
  }

  // 🔹 Simpan cicilan ke database Supabase
  Future<void> addInstallment(String debtId, Installment installment) async {
    try {
      final response = await supabase.from('installments').insert({
        'id': installment.id,
        'debt_id': debtId,
        'amount_paid': installment.amountPaid,
        'date_paid': installment.datePaid.toIso8601String(),
      });
      print(response);
      print("✅ Cicilan berhasil disimpan!");
    } catch (e) {
      print("❌ Error menyimpan cicilan: $e");
      throw e;
    }
  }

  // 🔹 Ambil daftar cicilan berdasarkan `debt_id`
  Future<List<Installment>> getInstallments(String debtId) async {
    try {
      final response = await supabase
          .from('installments')
          .select()
          .eq('debt_id', debtId)
          .order('date_paid', ascending: false);

      return response
          .map<Installment>((data) => Installment.fromJson(data))
          .toList();
    } catch (e) {
      print("❌ Error mengambil cicilan: $e");
      return [];
    }
  }
}

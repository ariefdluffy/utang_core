import 'package:logger/logger.dart';
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
      await supabase.from('debts').insert({
        'id': debt.id,
        'user_id': debt.userId,
        'title': debt.title,
        'amount': debt.amount,
        'created_at': DateTime.now().toIso8601String(),
      });

      // print("✅ Hutang berhasil disimpan!");
    } catch (e) {
      Logger().e("❌ Error saat menyimpan hutang ke Supabase: $e");
      rethrow;
    }
  }

  Future<List<Debt>> getDebts(String userId) async {
    try {
      final List<dynamic> response = await supabase
          .from('debts')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      // print(response);
      return response.map<Debt>((debt) => Debt.fromJson(debt)).toList();
    } catch (e) {
      Logger().e("❌ Error mengambil hutang dari Supabase: $e");
      return [];
    }
  }

  // 🔹 Simpan cicilan ke database Supabase
  Future<void> addInstallment(String debtId, Installment installment) async {
    try {
      await supabase.from('installments').insert({
        'id': installment.id,
        'debt_id': debtId,
        'amount_paid': installment.amountPaid,
        'date_paid': installment.datePaid.toUtc().toIso8601String(),
      });
      // // print(installment.amountPaid);
      // // print(installment.datePaid.toUtc().toIso8601String());
      // print("✅ Cicilan berhasil disimpan!");
    } catch (e) {
      Logger().e("❌ Error menyimpan cicilan: $e");
      rethrow;
    }
  }

  Future<List<Installment>> getInstallments(String debtId) async {
    try {
      final response = await supabase
          .from('installments')
          .select()
          .eq('debt_id', debtId)
          .order('date_paid', ascending: false);

      // print("🔹 Riwayat cicilan dari Supabase: $response");

      // if (response == null) {
      //   Logger().i("⚠️ Tidak ada cicilan ditemukan untuk debtId: $debtId");
      //   return [];
      // }

      // if (response is! List) {
      //   Logger()
      //       .e("❌ Error: Response bukan List, tipe: ${response.runtimeType}");
      //   return [];
      // }

      return (response as List<dynamic>)
          .map<Installment>((data) => Installment.fromJson(data))
          .toList();
    } catch (e) {
      Logger().e("❌ Error mengambil data cicilan: $e");
      return [];
    }
  }

  Future<void> updateDebt(
      String debtId, String newTitle, double newAmount, bool isPaid) async {
    try {
      await supabase.from('debts').update({
        'title': newTitle,
        'amount': newAmount,
        'is_paid': isPaid,
      }).eq('id', debtId);

      // print("✅ Hutang berhasil diperbarui!");
    } catch (e) {
      Logger().e("❌ Error saat memperbarui hutang: $e");
      rethrow;
    }
  }

  Future<void> updateDebtStatus(String debtId, bool isPaid) async {
    await supabase.from('debts').update({'is_paid': isPaid}).eq('id', debtId);
  }

  Future<void> deleteDebt(String debtId) async {
    try {
      // 🔹 Hapus semua cicilan terkait hutang
      await supabase.from('installments').delete().eq('debt_id', debtId);

      // 🔹 Hapus hutang utama
      await supabase.from('debts').delete().eq('id', debtId);

      Logger().i("✅ Hutang dan semua cicilannya berhasil dihapus!");
    } catch (e) {
      Logger().e("❌ Error saat menghapus hutang: $e");
      rethrow;
    }
  }

  Future<void> deleteInstallment(String installmentId) async {
    try {
      await supabase.from('installments').delete().eq('id', installmentId);
      // print("✅ Cicilan berhasil dihapus!");
    } catch (e) {
      Logger().d("❌ Error menghapus cicilan: $e");
      rethrow;
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utang_core/models/debt_model.dart';
import 'package:utang_core/models/installment_model.dart';
import 'package:utang_core/services/supabase_service.dart';

final debtProvider =
    StateNotifierProvider<DebtNotifier, List<Debt>>((ref) => DebtNotifier());

class DebtNotifier extends StateNotifier<List<Debt>> {
  DebtNotifier() : super([]);
  final _supabaseService = SupabaseService();

  final supabase = Supabase.instance.client;

  Future<void> addDebt(Debt debt) async {
    try {
      // 🔹 Simpan ke Supabase
      await _supabaseService.addDebt(debt);

      // 🔹 Jika sukses, tambahkan ke state lokal
      state = [...state, debt];
    } catch (e) {
      print("❌ Gagal menyimpan ke Supabase: $e");
    }
  }

  Future<void> fetchDebts(String userId) async {
    try {
      final debtsFromDb = await _supabaseService.getDebts(userId);
      state = debtsFromDb; // 🔹 Perbarui state dengan data dari Supabase
    } catch (e) {
      print("❌ Error mengambil data hutang: $e");
    }
  }

  Future<void> addInstallment(String debtId, Installment installment) async {
    try {
      await _supabaseService.addInstallment(
          debtId, installment); // Simpan ke Supabase

      // 🔹 Ambil ulang cicilan dari Supabase setelah menambahkan
      await fetchInstallments(debtId);
    } catch (e) {
      print("❌ Gagal menambahkan cicilan: $e");
    }
  }

  Future<void> fetchInstallments(String debtId) async {
    try {
      final installments = await _supabaseService.getInstallments(debtId);

      state = state.map((debt) {
        if (debt.id == debtId) {
          return Debt(
            id: debt.id,
            userId: debt.userId,
            title: debt.title,
            amount: debt.amount,
            installments:
                installments, // 🔹 Perbarui cicilan dengan data terbaru
          );
        }
        return debt;
      }).toList();
    } catch (e) {
      print(
          "❌ Error dari code debt_provider fetchInstallments mengambil data cicilan: $e");
    }
  }

  Future<List<Installment>> getInstallments(String debtId) async {
    try {
      final response = await supabase
          .from('installments')
          .select()
          .eq('debt_id', debtId)
          .order('date_paid', ascending: false);

      print("Riwayat cicilan $response");

      return response
          .map<Installment>((data) => Installment.fromJson(data))
          .toList();
    } catch (e) {
      print("❌ Error mengambil data cicilan: $e");
      return [];
    }
  }

  // ✅ Metode update hutang
  // void updateDebt(String debtId, String newTitle, double newAmount) {
  //   state = state.map((debt) {
  //     if (debt.id == debtId) {
  //       return Debt(
  //         id: debt.id,
  //         userId: debt.userId,
  //         title: newTitle,
  //         amount: newAmount,
  //         installments: debt.installments,
  //       );
  //     }
  //     Logger().e(debt);
  //     return debt;
  //   }).toList();
  // }
  Future<void> updateDebt(
      String debtId, String newTitle, double newAmount) async {
    try {
      await _supabaseService.updateDebt(
          debtId, newTitle, newAmount); // 🔹 Update di Supabase

      // 🔹 Perbarui state dengan data terbaru
      state = state.map((debt) {
        if (debt.id == debtId) {
          return Debt(
            id: debt.id,
            userId: debt.userId,
            title: newTitle,
            amount: newAmount,
            installments: debt.installments, // Cicilan tetap sama
          );
        }
        return debt;
      }).toList();
    } catch (e) {
      print("❌ Error mengupdate hutang: $e");
    }
  }

  Future<void> deleteDebt(String debtId) async {
    try {
      await _supabaseService.deleteDebt(debtId); // 🔹 Hapus dari Supabase

      // 🔹 Perbarui state Riverpod dengan menghapus hutang dari daftar
      state = state.where((debt) => debt.id != debtId).toList();
    } catch (e) {
      print("❌ Gagal menghapus hutang: $e");
    }
  }
}

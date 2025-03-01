import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:utang_core/models/debt_model.dart';
import 'package:utang_core/models/installment_model.dart';
import 'package:utang_core/services/supabase_service.dart';

final debtProvider =
    StateNotifierProvider<DebtNotifier, List<Debt>>((ref) => DebtNotifier());

class DebtNotifier extends StateNotifier<List<Debt>> {
  DebtNotifier() : super([]);
  final _supabaseService = SupabaseService();

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

  // 🔹 Simpan cicilan ke Supabase & perbarui state Riverpod
  Future<void> addInstallment(String debtId, Installment installment) async {
    try {
      await _supabaseService.addInstallment(
          debtId, installment); // Simpan ke Supabase

      // 🔹 Perbarui state dengan cicilan baru
      state = state.map((debt) {
        if (debt.id == debtId) {
          return Debt(
            id: debt.id,
            userId: debt.userId,
            title: debt.title,
            amount: debt.amount,
            installments: [...debt.installments, installment],
          );
        }
        return debt;
      }).toList();
    } catch (e) {
      print("❌ Gagal menambahkan cicilan: $e");
    }
  }

  // 🔹 Ambil cicilan dari Supabase & update state
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
            installments: installments,
          );
        }
        return debt;
      }).toList();
    } catch (e) {
      print("❌ Error mengambil cicilan: $e");
    }
  }

  // ✅ Metode update hutang
  void updateDebt(String debtId, String newTitle, double newAmount) {
    state = state.map((debt) {
      if (debt.id == debtId) {
        return Debt(
          id: debt.id,
          userId: debt.userId,
          title: newTitle,
          amount: newAmount,
          installments: debt.installments,
        );
      }
      return debt;
    }).toList();
  }
}

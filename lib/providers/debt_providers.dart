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
      Logger().i(installment.datePaid);
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
              createdAt: debt.createdAt,
              isPaid: debt.isPaid);
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
          .order('date_paid', ascending: true);

      print("Riwayat cicilan $response");

      return response
          .map<Installment>((data) => Installment.fromJson(data))
          .toList();
    } catch (e) {
      print("❌ Error mengambil data cicilan: $e");
      return [];
    }
  }

  Future<void> updateDebt(
      String debtId, String newTitle, double newAmount, bool isPaid) async {
    try {
      await _supabaseService.updateDebt(
          debtId, newTitle, newAmount, isPaid); // 🔹 Update di Supabase

      // 🔹 Perbarui state dengan data terbaru
      state = state.map((debt) {
        if (debt.id == debtId) {
          return Debt(
              id: debt.id,
              userId: debt.userId,
              title: newTitle,
              amount: newAmount,
              installments: debt.installments, // Cicilan tetap sama
              createdAt: debt.createdAt,
              isPaid: isPaid);
        }
        return debt;
      }).toList();
    } catch (e) {
      print("❌ Error mengupdate hutang: $e");
    }
  }

  Future<void> updateDebtStatus(String debtId, bool isPaid) async {
    try {
      await _supabaseService.updateDebtStatus(debtId, isPaid);

      Logger().i("is paid: $isPaid");
      // 🔹 Perbarui state hanya pada `isPaid`
      state = state.map((debt) {
        if (debt.id == debtId) {
          return Debt(
            id: debt.id,
            userId: debt.userId,
            title: debt.title, // Tetap sama
            amount: debt.amount, // Tetap sama
            installments: debt.installments, // Tetap sama
            createdAt: debt.createdAt, // Tetap sama
            isPaid: isPaid, // 🔹 Hanya isPaid yang berubah
          );
        }
        Logger().i("is paid: ${debt.isPaid}");
        return debt;
      }).toList();
    } catch (e) {
      print("❌ Error mengupdate status hutang: $e");
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

  Future<void> deleteInstallment(String debtId, String installmentId) async {
    try {
      await _supabaseService.deleteInstallment(installmentId);

      // 🔹 Perbarui state dengan menghapus cicilan dari daftar hutang terkait
      state = state.map((debt) {
        if (debt.id == debtId) {
          return Debt(
              id: debt.id,
              userId: debt.userId,
              title: debt.title,
              amount: debt.amount,
              installments: debt.installments
                  .where((i) => i.id != installmentId)
                  .toList(),
              createdAt: debt.createdAt,
              isPaid: debt.isPaid);
        }
        return debt;
      }).toList();
    } catch (e) {
      print("❌ Gagal menghapus cicilan: $e");
    }
  }
}

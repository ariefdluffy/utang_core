import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utang_core/providers/debt_providers.dart';
import 'package:utang_core/screen/edit_debt_screen.dart';
import 'package:utang_core/screen/pay_installment_screen.dart';
import 'package:utang_core/utils/snackbar_helper.dart';
import '../models/debt_model.dart';

class DebtCard extends ConsumerWidget {
  final Debt debt;

  const DebtCard({super.key, required this.debt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(debt.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text("Total: Rp. ${debt.amount.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Icon(Icons.payments, color: Colors.green),
                      SizedBox(width: 10),
                      Text("Bayar Cicilan"),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    EditDebtScreen(debt: debt)),
                          );
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: const Icon(Icons.payment, color: Colors.green),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    PayInstallmentScreen(debt: debt)),
                          );
                        },
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red), // 🔹 Tombol Hapus
                        onPressed: () {
                          _confirmDelete(context, ref);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Hutang?"),
          content: const Text(
              "Apakah Anda yakin ingin menghapus hutang ini beserta semua cicilannya?"),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context), // 🔹 Tutup dialog tanpa menghapus
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(debtProvider.notifier).deleteDebt(debt.id);
                  showSnackbar(context, "Hutang berhasil dihapus!",
                      isError: false);
                  Navigator.pop(
                      context); // 🔹 Tutup dialog setelah hapus sukses
                } catch (e) {
                  showSnackbar(
                      context, "Gagal menghapus hutang: ${e.toString()}");
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Hapus",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

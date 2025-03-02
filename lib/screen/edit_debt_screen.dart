import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utang_core/providers/debt_providers.dart';
import 'package:utang_core/utils/snackbar_helper.dart';
import '../models/debt_model.dart';

class EditDebtScreen extends ConsumerWidget {
  final Debt debt;

  EditDebtScreen({super.key, required this.debt});

  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  double _getTotalPaid() {
    return debt.installments
        .fold(0.0, (sum, installment) => sum + installment.amountPaid);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    titleController.text = debt.title;
    amountController.text = debt.amount.toString();

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Hutang")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Judul Hutang")),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Jumlah Hutang"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final newTitle = titleController.text;
                  final newAmount = double.tryParse(amountController.text);

                  if (newTitle.isEmpty || newAmount == null) {
                    showSnackbar(context, "Semua kolom harus diisi!");
                    return;
                  }

                  final totalPaid = _getTotalPaid();

                  // 🔹 Verifikasi jika hutang lebih kecil dari total cicilan
                  if (newAmount < totalPaid) {
                    showSnackbar(context,
                        "Jumlah hutang tidak boleh lebih kecil dari total cicilan (Rp. ${totalPaid.toStringAsFixed(2)})!");
                    return;
                  }

                  await ref
                      .read(debtProvider.notifier)
                      .updateDebt(debt.id, newTitle, newAmount);

                  showSnackbar(context, "Hutang berhasil diperbarui!",
                      isError: false);

                  Navigator.pop(context);
                } catch (e) {
                  showSnackbar(context, "Error: ${e.toString()}");
                }
              },
              child: const Text("Simpan Perubahan"),
            ),
          ],
        ),
      ),
    );
  }
}

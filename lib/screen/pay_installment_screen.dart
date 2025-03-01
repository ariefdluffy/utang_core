import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utang_core/models/debt_model.dart';
import 'package:utang_core/models/installment_model.dart';
import 'package:utang_core/providers/debt_providers.dart';
import 'package:utang_core/utils/snackbar_helper.dart';

class PayInstallmentScreen extends ConsumerWidget {
  final Debt debt;

  PayInstallmentScreen({required this.debt});

  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bayar Cicilan")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Total Hutang: \$${debt.amount.toStringAsFixed(2)}"),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Jumlah Bayar"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                try {
                  if (amountController.text.isEmpty) {
                    showSnackbar(context, "Masukkan jumlah pembayaran!");
                    return;
                  }

                  final installment = Installment(
                    id: DateTime.now().toString(),
                    amountPaid: double.parse(amountController.text),
                    datePaid: DateTime.now(),
                  );

                  ref
                      .read(debtProvider.notifier)
                      .addInstallment(debt.id, installment);
                  showSnackbar(context, "Pembayaran berhasil!", isError: false);
                  Navigator.pop(context);
                } catch (e) {
                  showSnackbar(context, "Error: ${e.toString()}");
                }
              },
              child: const Text("Bayar"),
            ),
          ],
        ),
      ),
    );
  }
}

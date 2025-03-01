import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utang_core/models/installment_model.dart';
import 'package:utang_core/providers/debt_providers.dart';
import '../models/debt_model.dart';
import '../utils/snackbar_helper.dart';

class PayInstallmentScreen_new extends ConsumerStatefulWidget {
  final Debt debt;

  PayInstallmentScreen_new({required this.debt});

  @override
  _PayInstallmentScreenState createState() => _PayInstallmentScreenState();
}

class _PayInstallmentScreenState
    extends ConsumerState<PayInstallmentScreen_new> {
  final TextEditingController amountController = TextEditingController();

  void _addInstallment() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Cicilan"),
          content: TextField(
            controller: amountController,
            decoration: const InputDecoration(labelText: "Jumlah Bayar"),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup dialog
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                try {
                  if (amountController.text.isEmpty) {
                    showSnackbar(context, "Masukkan jumlah pembayaran!");
                    return;
                  }

                  final amountPaid = double.tryParse(amountController.text);
                  if (amountPaid == null || amountPaid <= 0) {
                    showSnackbar(context, "Jumlah harus lebih dari 0!");
                    return;
                  }

                  final installment = Installment(
                    id: DateTime.now().toString(),
                    amountPaid: amountPaid,
                    datePaid: DateTime.now(),
                  );

                  ref
                      .read(debtProvider.notifier)
                      .addInstallment(widget.debt.id, installment);
                  showSnackbar(context, "Cicilan berhasil ditambahkan!",
                      isError: false);
                  Navigator.pop(context); // Tutup dialog setelah sukses
                  setState(() {}); // Perbarui UI
                } catch (e) {
                  showSnackbar(context, "Error: ${e.toString()}");
                }
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Cicilan")),
      body: widget.debt.installments.isEmpty
          ? const Center(child: Text("Belum ada cicilan"))
          : ListView.builder(
              itemCount: widget.debt.installments.length,
              itemBuilder: (context, index) {
                final installment = widget.debt.installments[index];
                return ListTile(
                  title: Text(
                      "Cicilan \$${installment.amountPaid.toStringAsFixed(2)}"),
                  subtitle: Text("Tanggal: ${installment.datePaid.toLocal()}"),
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addInstallment, // 🔹 Tambah cicilan saat ditekan
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

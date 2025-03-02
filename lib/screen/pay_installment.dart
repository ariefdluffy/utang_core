import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utang_core/models/installment_model.dart';
import 'package:utang_core/providers/debt_providers.dart';
import 'package:uuid/uuid.dart';
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
  final uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _fetchInstallments(); // 🔹 Ambil data cicilan saat halaman dibuka
  }

  void _fetchInstallments() {
    ref.read(debtProvider.notifier).fetchInstallments(widget.debt.id);
  }

  double _getTotalPaid(List<Installment> installments) {
    // return installments.fold(0.0, (sum, item) => sum + item.amountPaid);
    final updatedDebt = ref
        .read(debtProvider)
        .firstWhere((d) => d.id == widget.debt.id, orElse: () => widget.debt);
    return updatedDebt.installments
        .fold(0.0, (sum, item) => sum + item.amountPaid);
  }

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
              onPressed: () async {
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

                  final totalPaid = _getTotalPaid(widget.debt.installments);
                  final remainingDebt = widget.debt.amount - totalPaid;

                  // 🔹 Cek apakah hutang sudah lunas
                  if (totalPaid >= widget.debt.amount) {
                    showSnackbar(context,
                        "Hutang sudah lunas, tidak bisa menambah cicilan!");
                    return;
                  }

                  // 🔹 Cek apakah cicilan melebihi sisa hutang
                  if (amountPaid > remainingDebt) {
                    showSnackbar(context,
                        "Cicilan lebih besar dari sisa hutang! Maksimal: Rp. ${remainingDebt.toStringAsFixed(2)}");
                    return;
                  }

                  final installment = Installment(
                    id: uuid.v4(),
                    amountPaid: amountPaid,
                    datePaid: DateTime.now(),
                  );

                  await ref
                      .read(debtProvider.notifier)
                      .addInstallment(widget.debt.id, installment);
                  showSnackbar(context, "Cicilan berhasil ditambahkan!",
                      isError: false);

                  amountController.clear();
                  _fetchInstallments();

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
    final updatedDebt = ref
        .watch(debtProvider)
        .firstWhere((d) => d.id == widget.debt.id, orElse: () => widget.debt);
    final totalPaid = _getTotalPaid(updatedDebt.installments);
    final remainingDebt = updatedDebt.amount - totalPaid;

    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Cicilan")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Card(
              margin: const EdgeInsets.all(8),
              elevation: 5, // Menambahkan shadow untuk efek kedalaman
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    12), // Border radius yang lebih modern
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Hutang: Rp. ${updatedDebt.amount.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey, // Warna teks yang lebih modern
                      ),
                    ),
                    const SizedBox(height: 8), // Spasi antara teks
                    Text(
                      "Total Dibayar: Rp. ${totalPaid.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight:
                            FontWeight.w600, // Font weight yang lebih tebal
                      ),
                    ),
                    const SizedBox(height: 8), // Spasi antara teks
                    Text(
                      "Sisa Hutang: Rp. ${remainingDebt.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight:
                            FontWeight.w600, // Font weight yang lebih tebal
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: updatedDebt.installments.isEmpty
                ? const Center(child: Text("Belum ada cicilan"))
                : ListView.builder(
                    itemCount: updatedDebt.installments.length,
                    itemBuilder: (context, index) {
                      final installment = updatedDebt.installments[index];
                      return ListTile(
                        title: Text(
                            "Cicilan Rp. ${installment.amountPaid.toStringAsFixed(2)}"),
                        subtitle:
                            Text("Tanggal: ${installment.datePaid.toLocal()}"),
                        leading:
                            const Icon(Icons.check_circle, color: Colors.green),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addInstallment,
        backgroundColor: Colors.green, // 🔹 Tambah cicilan saat ditekan
        child: const Icon(Icons.add),
      ),
    );
  }
}

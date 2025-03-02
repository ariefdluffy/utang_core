import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utang_core/models/installment_model.dart';
import 'package:utang_core/providers/debt_providers.dart';
import 'package:uuid/uuid.dart';
import '../models/debt_model.dart';
import '../utils/snackbar_helper.dart';

// class PayInstallmentScreen extends ConsumerStatefulWidget {
//   final Debt debt;

//   PayInstallmentScreen({required this.debt});

//   @override
//   _PayInstallmentScreenState createState() => _PayInstallmentScreenState();
// }

// class _PayInstallmentScreenState extends ConsumerState<PayInstallmentScreen> {
//   final TextEditingController amountController = TextEditingController();
//   final uuid = const Uuid();

//   @override
//   void initState() {
//     super.initState();
//     _fetchInstallments(); // 🔹 Ambil data cicilan saat halaman dibuka
//   }

//   void _fetchInstallments() {
//     ref.read(debtProvider.notifier).fetchInstallments(widget.debt.id);
//   }

//   double _getTotalPaid(List<Installment> installments) {
//     // return installments.fold(0.0, (sum, item) => sum + item.amountPaid);
//     final updatedDebt = ref
//         .read(debtProvider)
//         .firstWhere((d) => d.id == widget.debt.id, orElse: () => widget.debt);
//     return updatedDebt.installments
//         .fold(0.0, (sum, item) => sum + item.amountPaid);
//   }

//   void _addInstallment() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Tambah Cicilan"),
//           content: TextField(
//             controller: amountController,
//             decoration: const InputDecoration(labelText: "Jumlah Bayar"),
//             keyboardType: TextInputType.number,
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context), // Tutup dialog
//               child: const Text("Batal"),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   if (amountController.text.isEmpty) {
//                     showSnackbar(context, "Masukkan jumlah pembayaran!");
//                     return;
//                   }

//                   final amountPaid = double.tryParse(amountController.text);
//                   if (amountPaid == null || amountPaid <= 0) {
//                     showSnackbar(context, "Jumlah harus lebih dari 0!");
//                     return;
//                   }

//                   final totalPaid = _getTotalPaid(widget.debt.installments);
//                   final remainingDebt = widget.debt.amount - totalPaid;

//                   // 🔹 Cek apakah hutang sudah lunas
//                   if (totalPaid >= widget.debt.amount) {
//                     showSnackbar(context,
//                         "Hutang sudah lunas, tidak bisa menambah cicilan!");
//                     return;
//                   }

//                   // 🔹 Cek apakah cicilan melebihi sisa hutang
//                   if (amountPaid > remainingDebt) {
//                     showSnackbar(context,
//                         "Cicilan lebih besar dari sisa hutang! Maksimal: Rp. ${remainingDebt.toStringAsFixed(2)}");
//                     return;
//                   }

//                   final installment = Installment(
//                     id: uuid.v4(),
//                     amountPaid: amountPaid,
//                     datePaid: DateTime.now(),
//                   );

//                   await ref
//                       .read(debtProvider.notifier)
//                       .addInstallment(widget.debt.id, installment);
//                   showSnackbar(context, "Cicilan berhasil ditambahkan!",
//                       isError: false);

//                   amountController.clear();
//                   _fetchInstallments();

//                   Navigator.pop(context); // Tutup dialog setelah sukses
//                   setState(() {}); // Perbarui UI
//                 } catch (e) {
//                   showSnackbar(context, "Error: ${e.toString()}");
//                 }
//               },
//               child: const Text("Simpan"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final updatedDebt = ref
//         .watch(debtProvider)
//         .firstWhere((d) => d.id == widget.debt.id, orElse: () => widget.debt);
//     final totalPaid = _getTotalPaid(updatedDebt.installments);
//     final remainingDebt = updatedDebt.amount - totalPaid;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Riwayat Cicilan")),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: MediaQuery.of(context).size.width,
//             child: Card(
//               margin: const EdgeInsets.all(8),
//               elevation: 5, // Menambahkan shadow untuk efek kedalaman
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(
//                     12), // Border radius yang lebih modern
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Total Hutang: Rp. ${updatedDebt.amount.toStringAsFixed(2)}",
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blueGrey, // Warna teks yang lebih modern
//                       ),
//                     ),
//                     const SizedBox(height: 8), // Spasi antara teks
//                     Text(
//                       "Total Dibayar: Rp. ${totalPaid.toStringAsFixed(2)}",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.green,
//                         fontWeight:
//                             FontWeight.w600, // Font weight yang lebih tebal
//                       ),
//                     ),
//                     const SizedBox(height: 8), // Spasi antara teks
//                     Text(
//                       "Sisa Hutang: Rp. ${remainingDebt.toStringAsFixed(2)}",
//                       style: const TextStyle(
//                         fontSize: 16,
//                         color: Colors.red,
//                         fontWeight:
//                             FontWeight.w600, // Font weight yang lebih tebal
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           const Divider(),
//           Expanded(
//             child: updatedDebt.installments.isEmpty
//                 ? const Center(child: Text("Belum ada cicilan"))
//                 : ListView.builder(
//                     itemCount: updatedDebt.installments.length,
//                     itemBuilder: (context, index) {
//                       final installment = updatedDebt.installments[index];
//                       return ListTile(
//                         title: Text(
//                             "Cicilan Rp. ${installment.amountPaid.toStringAsFixed(2)}"),
//                         subtitle:
//                             Text("Tanggal: ${installment.datePaid.toLocal()}"),
//                         leading:
//                             const Icon(Icons.check_circle, color: Colors.green),
//                       );
//                     },
//                   ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _addInstallment,
//         backgroundColor: Colors.green, // 🔹 Tambah cicilan saat ditekan
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

class PayInstallmentScreen extends ConsumerStatefulWidget {
  final Debt debt;

  PayInstallmentScreen({required this.debt});

  @override
  _PayInstallmentScreenState createState() => _PayInstallmentScreenState();
}

class _PayInstallmentScreenState extends ConsumerState<PayInstallmentScreen> {
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

  double _getTotalPaid() {
    final updatedDebt = ref.watch(debtProvider).firstWhere(
          (d) => d.id == widget.debt.id,
          orElse: () => widget.debt,
        );
    return updatedDebt.installments
        .fold(0.0, (sum, item) => sum + item.amountPaid);
  }

  void _addInstallment() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.add_circle_outline, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text("Tambah Cicilan",
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: InputDecoration(
                  labelText: "Jumlah Bayar",
                  prefixIcon:
                      const Icon(Icons.attach_money, color: Colors.green),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              const Text(
                "Masukkan jumlah cicilan yang ingin dibayarkan.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal",
                  style: TextStyle(color: Colors.redAccent)),
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

                  final totalPaid = _getTotalPaid();
                  final remainingDebt = widget.debt.amount - totalPaid;

                  if (totalPaid >= widget.debt.amount) {
                    showSnackbar(context,
                        "Hutang sudah lunas, tidak bisa menambah cicilan!");
                    return;
                  }

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

                  Navigator.pop(context);
                  setState(() {});
                } catch (e) {
                  showSnackbar(context, "Error: ${e.toString()}");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Simpan",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final updatedDebt = ref.watch(debtProvider).firstWhere(
          (d) => d.id == widget.debt.id,
          orElse: () => widget.debt,
        );
    final totalPaid = _getTotalPaid();
    final remainingDebt = updatedDebt.amount - totalPaid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Cicilan",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDebtInfo(
                        "Total Hutang", updatedDebt.amount, Colors.blueGrey),
                    _buildDebtInfo("Total Dibayar", totalPaid, Colors.green),
                    _buildDebtInfo("Sisa Hutang", remainingDebt, Colors.red),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: updatedDebt.installments.isEmpty
                ? const Center(
                    child: Text("Belum ada cicilan",
                        style: TextStyle(fontSize: 16)))
                : ListView.builder(
                    itemCount: updatedDebt.installments.length,
                    itemBuilder: (context, index) {
                      final installment = updatedDebt.installments[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(
                              "Rp. ${installment.amountPaid.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87)),
                          subtitle: Text(
                              "Tanggal: ${installment.datePaid.toLocal()}",
                              style: TextStyle(color: Colors.grey[700])),
                          leading: const Icon(Icons.check_circle,
                              color: Colors.green),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addInstallment,
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text("Tambah Cicilan"),
      ),
    );
  }

  Widget _buildDebtInfo(String title, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          Text("Rp. ${amount.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

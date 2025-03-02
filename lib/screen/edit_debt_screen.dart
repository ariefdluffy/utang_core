import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utang_core/providers/debt_providers.dart';
import 'package:utang_core/utils/snackbar_helper.dart';
import '../models/debt_model.dart';

// class EditDebtScreen extends ConsumerWidget {
//   final Debt debt;

//   EditDebtScreen({super.key, required this.debt});

//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();

//   double _getTotalPaid() {
//     return debt.installments
//         .fold(0.0, (sum, installment) => sum + installment.amountPaid);
//   }

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     titleController.text = debt.title;
//     amountController.text = debt.amount.toString();

//     return Scaffold(
//       appBar: AppBar(title: const Text("Edit Hutang")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//                 controller: titleController,
//                 decoration: const InputDecoration(labelText: "Judul Hutang")),
//             TextField(
//               controller: amountController,
//               decoration: const InputDecoration(labelText: "Jumlah Hutang"),
//               keyboardType: TextInputType.number,
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   final newTitle = titleController.text;
//                   final newAmount = double.tryParse(amountController.text);

//                   if (newTitle.isEmpty || newAmount == null) {
//                     showSnackbar(context, "Semua kolom harus diisi!");
//                     return;
//                   }

//                   final totalPaid = _getTotalPaid();

//                   // 🔹 Verifikasi jika hutang lebih kecil dari total cicilan
//                   if (newAmount < totalPaid) {
//                     showSnackbar(context,
//                         "Jumlah hutang tidak boleh lebih kecil dari total cicilan (Rp. ${totalPaid.toStringAsFixed(2)})!");
//                     return;
//                   }

//                   await ref
//                       .read(debtProvider.notifier)
//                       .updateDebt(debt.id, newTitle, newAmount);

//                   showSnackbar(context, "Hutang berhasil diperbarui!",
//                       isError: false);

//                   Navigator.pop(context);
//                 } catch (e) {
//                   showSnackbar(context, "Error: ${e.toString()}");
//                 }
//               },
//               child: const Text("Simpan Perubahan"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class EditDebtScreen extends ConsumerStatefulWidget {
  final Debt debt;

  EditDebtScreen({super.key, required this.debt});

  @override
  _EditDebtScreenState createState() => _EditDebtScreenState();
}

class _EditDebtScreenState extends ConsumerState<EditDebtScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.debt.title;
    amountController.text = widget.debt.amount.toString();
  }

  double _getTotalPaid() {
    return widget.debt.installments
        .fold(0.0, (sum, installment) => sum + installment.amountPaid);
  }

  void _updateDebt() async {
    final newTitle = titleController.text.trim();
    final newAmount = double.tryParse(amountController.text.trim());

    if (newTitle.isEmpty || newAmount == null) {
      showSnackbar(context, "Semua kolom harus diisi!");
      return;
    }

    final totalPaid = _getTotalPaid();

    // 🔹 Cek apakah jumlah hutang lebih kecil dari total cicilan yang telah dibayar
    if (newAmount < totalPaid) {
      showSnackbar(context,
          "Jumlah hutang tidak boleh lebih kecil dari total cicilan (Rp. ${totalPaid.toStringAsFixed(2)})!");
      return;
    }

    try {
      setState(() => isLoading = true);

      await ref
          .read(debtProvider.notifier)
          .updateDebt(widget.debt.id, newTitle, newAmount);
      showSnackbar(context, "Hutang berhasil diperbarui!", isError: false);

      Navigator.pop(context);
    } catch (e) {
      showSnackbar(context, "Error: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Hutang",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Perbarui Detail Hutang",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Judul Hutang",
                prefixIcon: const Icon(Icons.title, color: Colors.deepPurple),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: "Jumlah Hutang",
                prefixIcon: const Icon(Icons.attach_money, color: Colors.green),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _updateDebt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Simpan Perubahan",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

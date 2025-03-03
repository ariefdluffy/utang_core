import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:utang_core/models/debt_model.dart';
import 'package:utang_core/utils/snackbar_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:utang_core/providers/auth_providers.dart';
import 'package:utang_core/providers/debt_providers.dart';

// class AddDebtScreen extends ConsumerWidget {
//   final TextEditingController titleController = TextEditingController();
//   final TextEditingController amountController = TextEditingController();
//   final uuid = const Uuid();

//   AddDebtScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final user = ref.watch(userProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Tambah Hutang")),
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
//               onPressed: () {
//                 try {
//                   if (titleController.text.isEmpty ||
//                       amountController.text.isEmpty) {
//                     showSnackbar(context, "Semua kolom harus diisi!");
//                     return;
//                   }

//                   final newDebt = Debt(
//                     id: uuid.v4(),
//                     userId: user?.id ?? "",
//                     title: titleController.text,
//                     amount: double.parse(amountController.text),
//                     installments: [],
//                   );
//                   ref.read(debtProvider.notifier).addDebt(newDebt);

//                   Navigator.pop(context);
//                 } catch (e) {
//                   showSnackbar(context, "Error: ${e.toString()}");
//                 }
//               },
//               child: const Text("Tambah"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class AddDebtScreen extends ConsumerStatefulWidget {
  AddDebtScreen({super.key});

  @override
  _AddDebtScreenState createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final uuid = const Uuid();
  bool isLoading = false;

  void _addDebt() async {
    if (titleController.text.isEmpty || amountController.text.isEmpty) {
      showSnackbar(context, "Semua kolom harus diisi!");
      return;
    }

    final user = ref.read(userProvider);
    if (user == null) {
      showSnackbar(context, "Terjadi kesalahan! User tidak ditemukan.");
      return;
    }

    try {
      setState(() => isLoading = true);

      final newDebt = Debt(
        id: uuid.v4(),
        userId: user.id,
        title: titleController.text.trim(),
        amount: double.parse(amountController.text.trim()),
        installments: [],
        createdAt: DateTime.now(),
        isPaid: false,
      );

      await ref.read(debtProvider.notifier).addDebt(newDebt);

      showSnackbar(context, "Hutang berhasil ditambahkan!", isError: false);
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
        title: const Text("Tambah Hutang",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // const Text(
            //   "Masukkan Detail Hutang",
            //   style: TextStyle(
            //       fontSize: 20,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.black87),
            // ),
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
                onPressed: isLoading ? null : _addDebt,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Tambah Hutang",
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

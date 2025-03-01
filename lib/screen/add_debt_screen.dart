import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:utang_core/models/debt_model.dart';
import 'package:utang_core/utils/snackbar_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:utang_core/providers/auth_providers.dart';
import 'package:utang_core/providers/debt_providers.dart';

class AddDebtScreen extends ConsumerWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final uuid = const Uuid();

  AddDebtScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Hutang")),
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
              onPressed: () {
                try {
                  if (titleController.text.isEmpty ||
                      amountController.text.isEmpty) {
                    showSnackbar(context, "Semua kolom harus diisi!");
                    return;
                  }

                  final newDebt = Debt(
                    id: uuid.v4(),
                    userId: user?.id ?? "",
                    title: titleController.text,
                    amount: double.parse(amountController.text),
                    installments: [],
                  );
                  ref.read(debtProvider.notifier).addDebt(newDebt);

                  Navigator.pop(context);
                } catch (e) {
                  showSnackbar(context, "Error: ${e.toString()}");
                }
              },
              child: const Text("Tambah"),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:utang_core/screen/edit_debt_screen.dart';
import 'package:utang_core/screen/pay_installment.dart';
import '../models/debt_model.dart';

class DebtCard extends StatelessWidget {
  final Debt debt;

  const DebtCard({super.key, required this.debt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: ListTile(
          title: Text(debt.title),
          subtitle: Text("Total: Rp. ${debt.amount.toStringAsFixed(2)}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit,
                    color: Colors.blue), // 🔹 Tombol Edit
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditDebtScreen(debt: debt),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.payment,
                    color: Colors.green), // 🔹 Tombol Bayar Cicilan
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PayInstallmentScreen_new(debt: debt),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

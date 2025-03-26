import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:utang_core/models/installment_model.dart';
import 'package:utang_core/providers/debt_providers.dart';
import 'package:utang_core/utils/currency_helper.dart';
import 'package:utang_core/utils/date_helper.dart';
import 'package:utang_core/widget/interstitial_ad_widget.dart';
import 'package:uuid/uuid.dart';
import '../models/debt_model.dart';
import '../utils/snackbar_helper.dart';

class PayInstallmentScreen extends ConsumerStatefulWidget {
  final Debt debt;

  const PayInstallmentScreen({super.key, required this.debt});

  @override
  _PayInstallmentScreenState createState() => _PayInstallmentScreenState();
}

class _PayInstallmentScreenState extends ConsumerState<PayInstallmentScreen> {
  final TextEditingController amountController = TextEditingController();
  final uuid = const Uuid();

  final InterstitialAdHelper _adHelper = InterstitialAdHelper();

  bool isLoading = true;

  // Future<void> _loadAndSendDeviceInfo() async {
  //   try {
  //     await deviceInfoHelper.getAndSendDeviceInfo();
  //     setState(() {
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     Logger().e(e);
  //   }
  // }

  @override
  void initState() {
    super.initState();
    // _loadAndSendDeviceInfo();
    _fetchInstallments(); // 🔹 Ambil data cicilan saat halaman dibuka
    _adHelper.loadAd(() {
      Navigator.pop(context); // 🔄 Kembali ke Home setelah iklan ditutup
    });
  }

  /// 🔹 Tangani event "Back"
  bool _onWillPop() {
    _adHelper.showAd(context);
    return false; // ❌ Cegah navigasi langsung tanpa menampilkan iklan
  }

  @override
  void dispose() {
    _adHelper.disposeAd();
    super.dispose();
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                        datePaid: DateTime.now().toUtc(),
                      );

                      Logger().i(installment.datePaid);

                      await ref
                          .read(debtProvider.notifier)
                          .addInstallment(widget.debt.id, installment);

                      // 🔹 Cek apakah hutang masih ada setelah cicilan ditambahkan
                      final newTotalPaid = totalPaid + amountPaid;
                      final newRemainingDebt =
                          widget.debt.amount - newTotalPaid;

                      // print("ini sisa hutang $newRemainingDebt + $newTotalPaid");
                      // print("ini debt isPaid ${widget.debt.isPaid}");
                      // print("ini debt id ${widget.debt.id}");

                      if (newRemainingDebt > 0 && widget.debt.isPaid) {
                        await ref
                            .read(debtProvider.notifier)
                            .updateDebtStatus(widget.debt.id, false);
                        Logger().i(
                            "🔄 Status hutang diperbarui menjadi BELUM LUNAS (is_paid = false)");
                      }

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
                  child: const Text(
                    "Simpan",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _deleteInstallment(String installmentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Cicilan?"),
          content: const Text("Apakah Anda yakin ingin menghapus cicilan ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(debtProvider.notifier)
                      .deleteInstallment(widget.debt.id, installmentId);

                  // 🔹 Hitung ulang total pembayaran setelah cicilan dihapus
                  final totalPaid = _getTotalPaid();
                  final remainingDebt = widget.debt.amount - totalPaid;

                  // print(
                  //     "🔥 Sisa Hutang: $remainingDebt, Total Dibayar: $totalPaid");
                  // print("🔥 isPaid Sebelum Update: ${widget.debt.isPaid}");
                  // print("🔥 Debt ID: ${widget.debt.id}");

                  // 🔹 Jika masih ada hutang setelah cicilan dihapus, set isPaid = false
                  if (remainingDebt > 0 && widget.debt.isPaid) {
                    await ref
                        .read(debtProvider.notifier)
                        .updateDebtStatus(widget.debt.id, false);
                    Logger().i(
                        "🔄 Status hutang diperbarui menjadi BELUM LUNAS (is_paid = false)");
                  }

                  showSnackbar(context, "Cicilan berhasil dihapus!",
                      isError: false);
                  Navigator.pop(context); // 🔹 Tutup dialog setelah sukses
                  setState(() {}); // 🔹 Perbarui UI setelah cicilan dihapus
                } catch (e) {
                  showSnackbar(
                      context, "Gagal menghapus cicilan: ${e.toString()}");
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

  @override
  Widget build(BuildContext context) {
    final updatedDebt = ref.watch(debtProvider).firstWhere(
          (d) => d.id == widget.debt.id,
          orElse: () => widget.debt,
        );
    final totalPaid = _getTotalPaid();
    final remainingDebt = updatedDebt.amount - totalPaid;

    // 🔹 Jika sisa hutang = 0, update status hutang menjadi lunas
    if (remainingDebt == 0 && !updatedDebt.isPaid) {
      Future.microtask(() {
        ref.read(debtProvider.notifier).updateDebt(
              updatedDebt.id,
              updatedDebt.title, // 🔹 Gunakan title lama
              updatedDebt.amount, // 🔹 Gunakan jumlah hutang lama
              true, // 🔹 Ubah status menjadi lunas
            );
      });
    }

    return PopScope(
      canPop: false, // ❌ Blokir pop biasa agar bisa tampilkan iklan dulu
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Riwayat Cicilan",
              style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        updatedDebt
                            .title, // 🔹 Tambahkan Title Hutang dari tabel debts
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Divider(),
                      _buildDebtInfo(
                          "Total Hutang", updatedDebt.amount, Colors.blueGrey),
                      const Divider(),
                      _buildDebtInfo("Total Dibayar", totalPaid, Colors.green),
                      const Divider(),
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
                          style: TextStyle(fontSize: 14)))
                  : ListView.builder(
                      itemCount: updatedDebt.installments.length,
                      itemBuilder: (context, index) {
                        final installment = updatedDebt.installments[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            title: Text(
                                CurrencyHelper.formatRupiah(
                                    installment.amountPaid),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87)),
                            subtitle: Text(
                                DateHelper.formatTanggalLengkap(
                                    installment.datePaid),
                                // "Tanggal: ${installment.datePaid.toLocal()}",
                                style: const TextStyle(color: Colors.green)),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteInstallment(
                                  installment.id), // 🔹 Tombol hapus
                            ),
                            leading: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: Colors
                                    .green, // Warna latar belakang lingkaran
                                shape: BoxShape.circle, // Bentuk lingkaran
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // Warna teks putih
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
        bottomNavigationBar: remainingDebt >
                0 // 🔹 Tombol tambah cicilan hanya muncul jika hutang belum lunas
            ? Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: ElevatedButton(
                  onPressed: _addInstallment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "Tambah Cicilan",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              )
            : null, // 🔹 Jika hutang lunas, tombol tidak ditampilkan
      ),
    );
  }

  Widget _buildDebtInfo(String title, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          Text(CurrencyHelper.formatRupiah(amount),
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

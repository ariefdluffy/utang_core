import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utang_core/providers/auth_providers.dart';
import 'package:utang_core/providers/debt_providers.dart';
import 'package:utang_core/screen/auth/login_screen.dart';
import 'package:utang_core/screen/pay_installment_screen.dart';
import 'package:utang_core/utils/network_helper.dart';
import 'package:utang_core/utils/snackbar_helper.dart';
import 'package:utang_core/widget/banner_ad_widget.dart';
import 'package:utang_core/widget/debt_card.dart';
import 'auth/register_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isConnected = true;
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  @override
  void initState() {
    super.initState();
    _fetchDebts();

    //perubahan status koneksi internet
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      ConnectivityResult firstResult =
          result.isNotEmpty ? result.first : ConnectivityResult.none;

      setState(() {
        _isConnected = firstResult != ConnectivityResult.none;
      });

      if (_isConnected) {
        _fetchDebts(); // 🔹 Refresh data saat internet kembali tersedia
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel(); // 🔹 Hentikan listener saat halaman ditutup
    super.dispose();
  }

  void _fetchDebts() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      if (await NetworkHelper.hasInternetConnection()) {
        ref.read(debtProvider.notifier).fetchDebts(user.id);
      } else {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  void _logout() async {
    await ref.read(authProvider).signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
    showSnackbar(context, "Berhasil Logout!", isError: false);
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final debts = ref.watch(debtProvider);

    if (user == null) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
        );
      });
      return const Scaffold(
          body: Center(
              child:
                  CircularProgressIndicator())); // Placeholder sebelum navigasi
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Utang Core",
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(debtProvider.notifier).fetchDebts(user.id);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfo(user.email ?? ""),
            if (!_isConnected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.redAccent,
                child: const Text(
                  "⚠ Tidak ada koneksi internet!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 10),
            // BannerAdWidget(),
            Expanded(
              child: debts.isEmpty
                  ? const Center(
                      child: Text("Belum ada hutang",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500)))
                  : ListView.builder(
                      itemCount: debts.length,
                      itemBuilder: (context, index) {
                        final debt = debts[index];
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PayInstallmentScreen(debt: debt)));
                            // 🔹 Refresh data setelah kembali dari halaman cicilan
                            ref.read(debtProvider.notifier).fetchDebts(user.id);
                          },
                          child: DebtCard(debt: debts[index]),
                        ); // 🔹 Menampilkan DebtCard yang sudah diperbarui
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isConnected == true
          ? Container(
              padding: const EdgeInsets.all(16),
              color: Colors
                  .white, // 🔹 Latar belakang putih agar tombol terlihat jelas
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, "/add-debt"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      vertical: 16), // 🔹 Tombol lebih besar
                ),
                child: const Text(
                  "Tambah Hutang",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildUserInfo(String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.deepPurpleAccent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selamat datang,",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          Text(
            email,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

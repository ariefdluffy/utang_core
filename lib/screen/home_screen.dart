import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utang_core/providers/auth_providers.dart';
import 'package:utang_core/providers/debt_providers.dart';
import 'package:utang_core/screen/login_screen.dart';
import 'package:utang_core/widget/debt_card.dart';
import 'register_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _fetchDebts();
  }

  void _fetchDebts() {
    final user = Supabase.instance.client.auth.currentUser;
    // print(user);
    if (user != null) {
      ref.read(debtProvider.notifier).fetchDebts(user.id);
    }
  }

  void _logout() async {
    await ref.read(authProvider).signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    // Jika user logout, alihkan ke halaman Register
    if (user == null) {
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RegisterScreen()),
        );
      });
      return const Scaffold(
          body: Center(
              child:
                  CircularProgressIndicator())); // Placeholder sebelum navigasi
    }

    final debts = ref.watch(debtProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Catatan Hutang"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Text('Selamat datang, ${user.email} - ${user.id}'),
          const SizedBox(height: 10),
          Expanded(
            child: debts.isEmpty
                ? const Center(child: Text("Belum ada hutang"))
                : ListView.builder(
                    itemCount: debts.length,
                    itemBuilder: (context, index) {
                      return DebtCard(debt: debts[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, "/add-debt");
          _fetchDebts(); // Refresh data setelah menambahkan hutang
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

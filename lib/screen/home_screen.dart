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

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _fetchDebts();
//   }

//   void _fetchDebts() {
//     final user = Supabase.instance.client.auth.currentUser;
//     // print(user);
//     if (user != null) {
//       ref.read(debtProvider.notifier).fetchDebts(user.id);
//     }
//   }

//   void _logout() async {
//     await ref.read(authProvider).signOut();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => LoginScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = Supabase.instance.client.auth.currentUser;

//     // Jika user logout, alihkan ke halaman Register
//     if (user == null) {
//       Future.microtask(() {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => RegisterScreen()),
//         );
//       });
//       return const Scaffold(
//           body: Center(
//               child:
//                   CircularProgressIndicator())); // Placeholder sebelum navigasi
//     }

//     final debts = ref.watch(debtProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Hutang Core"),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: _logout,
//           ),
//         ],
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Center(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text('Selamat datang, ${user.email}'),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: debts.isEmpty
//                 ? const Center(child: Text("Belum ada hutang"))
//                 : ListView.builder(
//                     itemCount: debts.length,
//                     itemBuilder: (context, index) {
//                       return DebtCard(debt: debts[index]);
//                     },
//                   ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () async {
//           await Navigator.pushNamed(context, "/add-debt");
//           _fetchDebts(); // Refresh data setelah menambahkan hutang
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _fetchDebts();
  }

  void _fetchDebts() {
    final user = Supabase.instance.client.auth.currentUser;
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
        title: const Text("Hutang Core",
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserInfo(user.email ?? ""),
          const SizedBox(height: 10),
          Expanded(
            child: debts.isEmpty
                ? const Center(
                    child: Text("Belum ada hutang",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)))
                : ListView.builder(
                    itemCount: debts.length,
                    itemBuilder: (context, index) {
                      return DebtCard(
                          debt: debts[
                              index]); // 🔹 Menampilkan DebtCard yang sudah diperbarui
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color:
            Colors.white, // 🔹 Latar belakang putih agar tombol terlihat jelas
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, "/add-debt"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(
                vertical: 16), // 🔹 Tombol lebih besar
          ),
          child: const Text(
            "Tambah Hutang",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => Navigator.pushNamed(context, "/add-debt"),
      //   // icon: const Icon(Icons.add),
      //   // label: const Text(
      //   //   "Tambah",
      //   //   style: TextStyle(color: Colors.white),
      //   // ),
      //   backgroundColor: Colors.deepPurpleAccent,
      //   child: const Icon(
      //     Icons.add,
      //     color: Colors.white70,
      //   ),
      // ),
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

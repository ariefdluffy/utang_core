import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utang_core/config/supabase_config.dart';
import 'package:utang_core/router.dart';
import 'package:utang_core/screen/home_screen.dart';
import 'package:utang_core/screen/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize(); //
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    return MaterialApp(
      title: "Catatan Hutang",
      // initialRoute: "/",
      home: user == null
          ? LoginScreen()
          : const HomeScreen(), // 🔹 Tampilkan Register jika belum login,
      routes: routes,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

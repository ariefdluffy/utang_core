import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:utang_core/config/supabase_config.dart';
import 'package:utang_core/providers/debt_providers.dart';
import 'package:utang_core/router.dart';
import 'package:utang_core/screen/home_screen.dart';
import 'package:utang_core/screen/auth/login_screen.dart';
import 'package:utang_core/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();
  // await dotenv.load();
  await SupabaseConfig.initialize(); //

  await initializeDateFormatting('id_ID', null);

  await LocalStorageService.getOfflineDebts();
  await LocalStorageService.getOfflineInstallments();

  await LocalStorageService.debugPrintAllSharedPreferences();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    _syncDataIfConnected();
  }

  // 🔹 Sinkronisasi data offline ke Supabase jika ada koneksi internet
  void _syncDataIfConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      Future.microtask(() {
        ref.read(debtProvider.notifier).syncOfflineDebts();
        ref.read(debtProvider.notifier).syncOfflineInstallments();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return MaterialApp(
      title: "Catatan Utang",
      home: user == null ? const LoginScreen() : const HomeScreen(),
      routes: routes,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}

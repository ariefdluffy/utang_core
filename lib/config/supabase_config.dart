import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  // static const String supabaseUrl = "https://hhwyirueqkorkoctezoz.supabase.co";
  // static const String supabaseAnonKey =
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhod3lpcnVlcWtvcmtvY3Rlem96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEwNjk5MDcsImV4cCI6MjA1NjY0NTkwN30.E6PXf_8Q2CNmC6TfZjSMPwlZVjVWcJIVLgVek9Lt3rc";

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = "https://xhgvxxdpudrznioaysyb.supabase.co";
  static const String supabaseAnonKey =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhoZ3Z4eGRwdWRyem5pb2F5c3liIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDAyNjYyOTQsImV4cCI6MjA1NTg0MjI5NH0.36CHElWRfnaaMWBaxNx98wx3SjbvQ0yTiCheN-B7GOw";

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}

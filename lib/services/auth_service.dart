import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // final SupabaseClient _supabase = SupabaseConfig.instance.client;
  static final supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final isLoadingProvider = StateProvider<bool>((ref) => false);

  Future<bool> signInWithGoogle(WidgetRef ref) async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.disconnect(); // Hapus cache akun Google

    try {
      ref.read(isLoadingProvider.notifier).state = true; // Aktifkan loading
      const webClientId =
          '478422750489-cit0gqsj8aaik0d6udv96alhtm4khlqk.apps.googleusercontent.com';

      ///
      /// iOS Client ID that you registered with Google Cloud.
      // const iosClientId = 'my-ios.apps.googleusercontent.com';
      // Logout terlebih dahulu agar pengguna diminta memilih akun lagi
      await supabase.auth.signOut();

      final GoogleSignIn googleSignIn = GoogleSignIn(
        // clientId: iosClientId,
        serverClientId: webClientId,
      );
      // Paksa pengguna memilih akun Google

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        ref.read(isLoadingProvider.notifier).state = false;
        Logger().e("Login dibatalkan.");
        return false;
      }

      final googleAuth = await googleUser!.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // await supabase.auth.signInWithOAuth(
      //   OAuthProvider.google,
      //   // authScreenLaunchMode:
      //   //     LaunchMode.externalApplication, // Untuk mencegah error di Android
      //   // forceRefresh: true, // Memaksa pengguna memilih akun setiap kali login
      // );
      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      // final session = supabase.auth.currentSession;

      return response.session != null;
    } catch (e) {
      Logger().e("❌ Error Google Sign-In: $e");
      ref.read(isLoadingProvider.notifier).state = false;
      return false;
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    await _googleSignIn.signOut();
    await _googleSignIn.disconnect();
  }
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  // final SupabaseClient _supabase = SupabaseConfig.instance.client;
  static final supabase = Supabase.instance.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final isLoadingProvider = StateProvider<bool>((ref) => false);

  Future<bool> signInWithGoogle() async {
    try {
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];

      /// iOS Client ID that you registered with Google Cloud.
      // const iosClientId = 'my-ios.apps.googleusercontent.com';
      // Logout terlebih dahulu agar pengguna diminta memilih akun lagi
      // await supabase.auth.signOut();

      final GoogleSignIn googleSignIn = GoogleSignIn(
        // clientId: iosClientId,
        serverClientId: webClientId,
      );
      // Paksa pengguna memilih akun Google

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        Logger().e("Login dibatalkan.");
        return false;
      } else {
        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;

        if (idToken == null) {
          throw 'No ID Token found.';
        }

        await supabase.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
        );
        return true;
      }
    } catch (e) {
      Logger().e("❌ Error Google Sign-In: $e");

      return false;
    } finally {}
  }

  // Future<void> signInWithGoogle() async {
  //   try {
  //     await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google,
  //         authScreenLaunchMode: LaunchMode.inAppWebView);
  //   } catch (error) {
  //     print('Error saat login: $error');
  //   }
  // }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    await supabase.auth.signOut();
  }
}

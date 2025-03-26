import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utang_core/providers/auth_providers.dart';
import 'package:utang_core/screen/auth/register_screen.dart';
import 'package:utang_core/services/auth_service.dart';
import 'package:utang_core/utils/snackbar_helper.dart';
import 'package:utang_core/widget/disclaimer_dialog.dart';

// class LoginScreen extends ConsumerWidget {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();

//   LoginScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authService = ref.watch(authProvider);

//     return Scaffold(
//       appBar: AppBar(title: const Text("Login")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//                 controller: emailController,
//                 decoration: const InputDecoration(labelText: "Email")),
//             TextField(
//                 controller: passwordController,
//                 decoration: const InputDecoration(labelText: "Password"),
//                 obscureText: true),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () async {
//                 try {
//                   final user = await authService.signIn(
//                       emailController.text, passwordController.text);
//                   if (user != null) {
//                     Navigator.pushReplacementNamed(context, "/home");
//                   } else {
//                     showSnackbar(context,
//                         "Login gagal, periksa kembali email dan password.");
//                   }
//                 } catch (e) {
//                   showSnackbar(context, "Error: ${e.toString()}");
//                 }
//               },
//               child: const Text("Login"),
//             ),
//             const SizedBox(height: 10),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           RegisterScreen()), // 🔹 Menuju Halaman Register
//                 );
//               },
//               child: const Text("Belum punya akun? Daftar"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void _login() async {
    setState(() => isLoading = true);
    try {
      final user = await ref.read(authProvider).signIn(
            emailController.text.trim(),
            passwordController.text.trim(),
          );

      if (user != null) {
        showSnackbar(context, "Login berhasil!", isError: false);
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        showSnackbar(
            context, "Login gagal, periksa kembali email dan password.");
      }
    } catch (e) {
      showSnackbar(context, "Error: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.indigoAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Login | Utang Core",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text("Mengelola catatan hutang Anda",
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Login",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Divider(),
                    SizedBox(
                      width: double.infinity, // Full width
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final success =
                                await AuthService().signInWithGoogle();
                            if (success) {
                              Navigator.pushReplacementNamed(context, "/home");
                              showSnackbar(context, "Login berhasil.",
                                  isError: false);
                            }
                          } catch (e) {
                            showSnackbar(context, "Error: ${e.toString()}");
                          }
                        },
                        icon: Image.asset(
                          'assets/logo_google.png', // Pastikan ikon Google ada di assets/icons/
                          height: 24,
                        ),
                        label: const Text(
                          "Sign in with Google",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreen()),
                          );
                        },
                        child: const Text("Belum punya akun? Klik Daftar",
                            style: TextStyle(
                                fontSize: 14, color: Colors.deepPurpleAccent)),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.info_outline,
                          color: Colors.deepPurpleAccent),
                      title: const Text("Disclaimer"),
                      onTap: () {
                        showDisclaimerDialog(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

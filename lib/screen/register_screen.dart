import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:utang_core/providers/auth_providers.dart';
import 'package:utang_core/utils/snackbar_helper.dart';

class RegisterScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Registrasi")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email")),
            TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true),
            TextField(
                controller: confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: "Konfirmasi Password"),
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  if (passwordController.text !=
                      confirmPasswordController.text) {
                    showSnackbar(context, "Password tidak cocok.");
                    return;
                  }

                  final user = await authService.signUp(
                      emailController.text, passwordController.text);
                  if (user != null) {
                    Navigator.pushReplacementNamed(context, "/home");
                  } else {
                    showSnackbar(context, "Registrasi gagal.");
                  }
                } catch (e) {
                  showSnackbar(context, "Error: ${e.toString()}");
                }
              },
              child: const Text("Daftar"),
            ),
          ],
        ),
      ),
    );
  }
}

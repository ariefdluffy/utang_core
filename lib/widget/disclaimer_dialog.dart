import 'package:flutter/material.dart';

void showDisclaimerDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // 🔹 Dialog tidak bisa ditutup dengan klik luar
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "📌 Disclaimer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const SingleChildScrollView(
          child: Text(
            "Aplikasi Utang Core menyimpan data pengguna secara online di server Kami.\n\n"
            "Selama Anda masih mengingat email dan password akun, data Anda akan tetap aman dan bisa diakses kapan saja.\n\n"
            "Kami tidak bertanggung jawab atas kehilangan akun akibat lupa password atau akses tidak sah. "
            "Pastikan Anda menggunakan email yang valid dan mengamankan akun Anda dengan baik.",
            textAlign: TextAlign.justify,
            style: TextStyle(fontSize: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 🔹 Tutup dialog
            },
            child: const Text(
              "Saya Mengerti",
              style: TextStyle(fontSize: 16, color: Colors.deepPurpleAccent),
            ),
          ),
        ],
      );
    },
  );
}

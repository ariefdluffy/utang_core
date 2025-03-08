import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // 🔹 Fungsi untuk membuka tautan donasi
  void _launchDonationURL() async {
    final Uri url = Uri.parse(
        "https://www.buymeacoffee.com/miftahularif.dev"); // Ganti dengan link donasi Anda
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("❌ Tidak dapat membuka tautan donasi.");
    }
  }

  // 🔹 Fungsi untuk mengirim email ke developer
  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'miftahularif.dev@gmail.com',
      query: 'subject=Dukungan Aplikasi Hutang Core',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      debugPrint("❌ Tidak dapat membuka email.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tentang Aplikasi"),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Logo Aplikasi
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(50),
            //   child: Image.asset(
            //     "assets/logo.png", // Ganti dengan logo aplikasi Anda
            //     width: 100,
            //     height: 100,
            //   ),
            // ),
            // const SizedBox(height: 16),

            // 🔹 Nama Aplikasi
            const Text(
              "Utang Core",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // 🔹 Versi Aplikasi
            const Text(
              "Versi 1.1.0",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // 🔹 Deskripsi Aplikasi
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Aplikasi Utang Core membantu Anda mencatat hutang dan cicilan dengan mudah. "
                      "Dilengkapi dengan fitur laporan dan notifikasi untuk mengingatkan pembayaran hutang.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email, color: Colors.deepPurpleAccent),
                        SizedBox(width: 8),
                        Text("miftahularif.dev@gmail.com",
                            style: TextStyle(
                                color: Colors.deepPurpleAccent,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Tombol Donasi
            // ElevatedButton.icon(
            //   onPressed: _launchDonationURL,
            //   icon: const Icon(Icons.favorite, color: Colors.white),
            //   label: const Text(
            //     "Dukung dengan Donasi",
            //     style: TextStyle(
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //         color: Colors.white),
            //   ),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.orange,
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            //     shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12)),
            //   ),
            // ),
            const SizedBox(height: 10),

            // 🔹 Tombol Hubungi Developer
            ElevatedButton.icon(
              onPressed: _sendEmail,
              icon: const Icon(Icons.email, color: Colors.white),
              label: const Text(
                "Hubungi Developer",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),

            // 🔹 Copyright / Credit
            const Text(
              "© 2025 Utang Core - Dibuat dengan ❤️ oleh Miftahul arif",
              style: TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utang_core/ads/ad_banner_about.dart';
import 'package:utang_core/utils/date_helper.dart';

class AboutPage extends ConsumerWidget {
  const AboutPage({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final bannerAd = ref.watch(bannerAdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "About Me",
        ),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.mail, color: Colors.blue),
                title: const Text("Email",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${user!.email}",
                    style: const TextStyle(fontSize: 12)),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.shield_outlined, color: Colors.green),
                title: const Text("Status",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(user.aud, style: const TextStyle(fontSize: 12)),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.orange),
                title: const Text("Dibuat",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(formatTanggal(user.createdAt),
                    style: const TextStyle(fontSize: 12)),
              ),
              const Divider(),
              ListTile(
                leading:
                    const Icon(Icons.calendar_month, color: Colors.blueAccent),
                title: const Text("Terakhir Log-In",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(formatTanggal('${user.lastSignInAt}'),
                    style: const TextStyle(fontSize: 12)),
              ),
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
              // const Text(
              //   "Utang Core",
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),

              // 🔹 Versi Aplikasi
              // const Text(
              //   "Versi 1.1.0",
              //   style: TextStyle(fontSize: 12, color: Colors.grey),
              // ),
              const Divider(),
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
                        "Utang Core",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Aplikasi Utang Core membantu Anda mencatat hutang dan cicilan dengan mudah. ",
                        // "Dilengkapi dengan fitur laporan dan notifikasi untuk mengingatkan pembayaran hutang.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email,
                              size: 16, color: Colors.deepPurpleAccent),
                          SizedBox(width: 8),
                          Text("Kirim E-Mail",
                              style: TextStyle(
                                  color: Colors.deepPurpleAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
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
              // ElevatedButton.icon(
              //   onPressed: _sendEmail,
              //   icon: const Icon(Icons.email, color: Colors.white),
              //   label: const Text(
              //     "Hubungi Developer",
              //     style: TextStyle(
              //         fontSize: 12,
              //         fontWeight: FontWeight.bold,
              //         color: Colors.white),
              //   ),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.blueAccent,
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 30),

              // 🔹 Copyright / Credit
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  children: [
                    const TextSpan(
                        text:
                            "© 2025 Utang Core V1.1.1 - \nDibuat dengan ❤️ oleh "),
                    TextSpan(
                      text: "Miftahularif",
                      style: const TextStyle(
                        color: Colors.blue, // Warna teks yang dapat diklik
                        decoration: TextDecoration
                            .underline, // Garis bawah untuk menunjukkan bahwa teks dapat diklik
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Fungsi untuk mengirim email
                          _sendEmail();
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              if (bannerAd != null &&
                  bannerAd.responseInfo !=
                      null) // 🔹 Menampilkan Banner Ads jika berhasil dimuat
                SizedBox(
                  height: bannerAd.size.height.toDouble(),
                  width: bannerAd.size.width.toDouble(),
                  child: AdWidget(ad: bannerAd),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

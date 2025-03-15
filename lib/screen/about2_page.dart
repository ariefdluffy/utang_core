import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:utang_core/utils/date_helper.dart';
import 'package:utang_core/widget/interstitial_ad_widget.dart';

class AboutPageNew extends ConsumerStatefulWidget {
  const AboutPageNew({super.key});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPageNew> {
  BannerAd? _bannerAd;
  final user = Supabase.instance.client.auth.currentUser;
  final InterstitialAdHelper _adHelper = InterstitialAdHelper();

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  /// 🔹 Tangani event "Back"
  bool _onWillPop() {
    _adHelper.showAd(context);
    return false; // ❌ Cegah navigasi langsung tanpa menampilkan iklan
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final banner = BannerAd(
      size: AdSize.banner,
      adUnitId:
          'ca-app-pub-2393357737286916/4101960758', // Ganti dengan ID asli
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _bannerAd = null;
          });
        },
      ),
      request: const AdRequest(),
    );

    banner.load();
  }

  Future<void> _sendEmail() async {
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
    return PopScope(
      canPop: false, // ❌ Blokir pop biasa agar bisa tampilkan iklan dulu
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onWillPop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("About Me"),
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
                  subtitle: Text(user?.email ?? "Tidak diketahui",
                      style: const TextStyle(fontSize: 12)),
                ),
                const Divider(),
                ListTile(
                  leading:
                      const Icon(Icons.shield_outlined, color: Colors.green),
                  title: const Text("Status",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(user?.aud ?? "Tidak diketahui",
                      style: const TextStyle(fontSize: 12)),
                ),
                const Divider(),
                ListTile(
                  leading:
                      const Icon(Icons.calendar_month, color: Colors.orange),
                  title: const Text("Dibuat",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      user != null ? formatTanggal(user!.createdAt) : "-",
                      style: const TextStyle(fontSize: 12)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.calendar_month,
                      color: Colors.blueAccent),
                  title: const Text("Terakhir Log-In",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      user != null
                          ? formatTanggal('${user!.lastSignInAt}')
                          : "-",
                      style: const TextStyle(fontSize: 12)),
                ),
                const Divider(),
                const SizedBox(height: 16),

                // 🔹 Deskripsi Aplikasi
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          "Utang Core",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Aplikasi Utang Core membantu Anda mencatat hutang dan cicilan dengan mudah.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: _sendEmail,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.email,
                                  size: 16, color: Colors.deepPurpleAccent),
                              const SizedBox(width: 8),
                              Text("Kirim E-Mail",
                                  style: TextStyle(
                                      color: Colors.deepPurpleAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

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
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = _sendEmail,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // 🔹 Banner Iklan
                if (_bannerAd != null)
                  SizedBox(
                    height: _bannerAd!.size.height.toDouble(),
                    width: _bannerAd!.size.width.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

class InterstitialAdHelper {
  InterstitialAd? _interstitialAd;

  /// 🔹 Muat iklan Interstitial
  void loadAd(VoidCallback onAdDismissed) {
    InterstitialAd.load(
      adUnitId:
          'ca-app-pub-2393357737286916/6618035772', // Ganti dengan ID asli
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          _interstitialAd?.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              onAdDismissed(); // 🔄 Panggil callback setelah iklan ditutup
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
              ad.dispose();
              onAdDismissed(); // 🔄 Tetap kembali jika iklan gagal tampil
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          Logger().e("❌ Gagal memuat iklan: $error");
          _interstitialAd = null;
        },
      ),
    );
  }

  /// 🔹 Tampilkan iklan jika tersedia
  void showAd(BuildContext context) {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
    } else {
      Navigator.pop(context); // Jika iklan tidak ada, langsung kembali
    }
  }

  /// 🔹 Bersihkan iklan setelah digunakan
  void disposeAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

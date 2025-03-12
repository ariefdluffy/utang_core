import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

final bannerAdProvider =
    StateNotifierProvider<BannerAdNotifier, BannerAd?>((ref) {
  final provider = BannerAdNotifier();
  // ref.keepAlive(); // ✅ Menjaga agar iklan tidak dihapus saat halaman berubah
  return provider;
});

class BannerAdNotifier extends StateNotifier<BannerAd?> {
  BannerAdNotifier() : super(null) {
    _loadBannerAdAtas();
  }

  void _loadBannerAdAtas() async {
    final BannerAd banner = BannerAd(
      size: AdSize.banner,
      adUnitId:
          'ca-app-pub-2393357737286916/4101960758', // ✅ Ganti dengan ID asli
      listener: BannerAdListener(
        onAdLoaded: (ad) => state = ad as BannerAd,
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          state = null;
        },
      ),
      request: const AdRequest(),
    );
    banner.load();
  }

  void reloadAd() {
    state?.dispose(); // Hapus instance sebelumnya
    _loadBannerAdAtas(); // Muat ulang iklan baru
  }
}

final bannerAdProviderNew = Provider.autoDispose<BannerAd?>((ref) {
  final BannerAd bannerAd = BannerAd(
    size: AdSize.banner,
    adUnitId:
        'ca-app-pub-2393357737286916/9911786677', // ✅ Ganti dengan ID Asli
    listener: BannerAdListener(
      onAdLoaded: (ad) => ref.onDispose(() => ad.dispose()),
      onAdFailedToLoad: (ad, error) {
        Logger().e("Ad Failed to Load: $error");
        ad.dispose();
      },
    ),
    request: const AdRequest(),
  );

  bannerAd.load(); // ✅ Pastikan iklan dimuat sebelum ditampilkan
  return bannerAd;
});

import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:utang_core/utils/tele_helper.dart';

class DeviceInfoHelper {
  final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  final TelegramHelper telegramHelper;
  // final sendCount = 0;

  DeviceInfoHelper({required this.telegramHelper});

  // Method untuk mendapatkan informasi perangkat dan mengirim ke Telegram
  Future<void> getAndSendDeviceInfo() async {
    try {
      // Periksa batasan pengiriman
      if (await _canSendMessage()) {
        String deviceId = 'Unknown';
        String model = 'Unknown';
        String manufacturer = 'Unknown';
        // String type = 'Unknown';
        String brand = 'Unknown';
        String name = 'Unknown';
        String product = 'Unknown';
        String device = 'Unknown';
        String version = 'Unknown';

        if (Platform.isAndroid) {
          // Jika platform Android
          AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;
          deviceId = androidInfo.id; // Device ID
          model = androidInfo.model; // Model perangkat
          manufacturer = androidInfo.manufacturer; // Pabrikan perangkat
          // type = androidInfo.type;
          brand = androidInfo.brand;
          // serialNumber = androidInfo.serialNumber;
          product = androidInfo.product;
          name = androidInfo.name;
          device = androidInfo.device;
          version = androidInfo.version.release;
        } else if (Platform.isIOS) {
          // Jika platform iOS
          IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? 'Unknown'; // Device ID
          model = iosInfo.model ?? 'Unknown'; // Model perangkat
          manufacturer = 'Apple'; // Pabrikan perangkat
        }

        // Buat pesan log
        String message = 'Aplikasi Utang Core dibuka oleh pengguna:\n'
            '- Device ID: $deviceId\n'
            '- Model: $model\n'
            '- Manufacturer: $manufacturer\n'
            // '- Id HP: $type\n'
            '- Brand: $brand\n'
            '- Name: $name\n'
            '- Produk: $product\n'
            '- Device: $device\n'
            '- Version: $version\n'
            // '- Serial Number: $serialNumber\n'
            '- Waktu: ${DateTime.now()}';

        // Kirim pesan ke Telegram
        await telegramHelper.sendMessage(message);

        // Simpan waktu pengiriman terakhir dan jumlah pengiriman
        await _updateSendStatus();
      } else {
        Logger().i(
            'Batas pengiriman pesan telah tercapai (maksimal 1 kali per 2 Jam).');
      }
    } catch (e) {
      throw Exception(
          'Gagal mendapatkan atau mengirim informasi perangkat: $e');
    }
  }

  // Method untuk memeriksa apakah pesan bisa dikirim
  Future<bool> _canSendMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSendTime = prefs.getInt('lastSendTime') ?? 0;
    final sendCount = prefs.getInt('sendCount') ?? 0;

    final now = DateTime.now().millisecondsSinceEpoch;
    const oneHourInMillis = 2 * 60 * 60 * 1000; // 1 jam dalam milidetik

    // Jika lebih dari 1 jam sejak pengiriman terakhir, reset counter
    if (now - lastSendTime > oneHourInMillis) {
      await prefs.setInt('sendCount', 0); // Reset jumlah pengiriman
      await prefs.setInt(
          'lastSendTime', now); // Update waktu pengiriman terakhir
      return true;
    }

    // Periksa apakah jumlah pengiriman kurang dari 2
    return sendCount < 1;
  }

  // Method untuk memperbarui status pengiriman
  Future<void> _updateSendStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final sendCount = prefs.getInt('sendCount') ?? 0;

    // Update jumlah pengiriman dan waktu terakhir
    await prefs.setInt('sendCount', sendCount + 1);
    await prefs.setInt('lastSendTime', DateTime.now().millisecondsSinceEpoch);
  }
}

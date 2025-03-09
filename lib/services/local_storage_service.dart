import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utang_core/models/debt_model.dart';
import '../models/installment_model.dart';

class LocalStorageService {
  static const String _offlineInstallmentsKey = "offline_installments";
  static const String _offlineDebtsKey = "offline_debts";

  // 🔹 Simpan cicilan ke penyimpanan lokal
  static Future<void> saveOfflineInstallments(
      List<Installment> installments) async {
    final prefs = await SharedPreferences.getInstance();
    final installmentsJson = installments.map((i) => i.toJson()).toList();
    await prefs.setString(
        _offlineInstallmentsKey, jsonEncode(installmentsJson));
  }

  // 🔹 Ambil data cicilan dari penyimpanan lokal
  static Future<List<Installment>> getOfflineInstallments() async {
    final prefs = await SharedPreferences.getInstance();
    final installmentsString = prefs.getString(_offlineInstallmentsKey);

    if (installmentsString == null) return [];

    final List<dynamic> decodedData = jsonDecode(installmentsString);
    return decodedData.map((data) => Installment.fromJson(data)).toList();
  }

  // 🔹 Simpan hutang ke penyimpanan lokal
  static Future<void> saveOfflineDebts(List<Debt> debts) async {
    final prefs = await SharedPreferences.getInstance();
    final debtsJson = debts.map((debt) => debt.toJson()).toList();
    await prefs.setString(_offlineDebtsKey, jsonEncode(debtsJson));
    Logger().i("saveoffline $prefs");
  }

  // 🔹 Ambil data hutang dari penyimpanan lokal
  static Future<List<Debt>> getOfflineDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtsString = prefs.getString(_offlineDebtsKey);
    Logger().i("getOffline $debtsString");
    if (debtsString == null) return [];

    final List<dynamic> decodedData = jsonDecode(debtsString);
    return decodedData.map((data) => Debt.fromJson(data)).toList();
  }

  // 🔹 Hapus data cicilan setelah disinkronkan ke server
  static Future<void> clearOfflineInstallments() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_offlineInstallmentsKey);
  }

  // 🔹 Hapus data hutang setelah disinkronkan ke server
  static Future<void> clearOfflineDebts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_offlineDebtsKey);
  }

  static Future<void> debugPrintAllSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final allData =
        prefs.getKeys().map((key) => {key: prefs.get(key)}).toList();

    Logger().i("Data SharedPreferences $allData");
  }
}

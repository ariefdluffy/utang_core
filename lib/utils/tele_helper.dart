import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class TelegramHelper {
  final String botToken;
  final String chatId;

  TelegramHelper({required this.botToken, required this.chatId});

  // Method untuk mengirim pesan ke Telegram
  Future<void> sendMessage(String message) async {
    final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
    final response = await http.post(
      url,
      body: {
        'chat_id': chatId,
        'text': message,
      },
    );

    if (response.statusCode == 200) {
      Logger().i('Pesan berhasil dikirim ke Telegram');
    } else {
      Logger().e('Gagal mengirim pesan: ${response.body}');
      throw Exception('Gagal mengirim pesan ke Telegram');
    }
  }
}

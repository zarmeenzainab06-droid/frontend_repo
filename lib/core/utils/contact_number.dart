import 'package:url_launcher/url_launcher.dart';

class contactnumber {
  static Future<void> openChat(String phone, {String message = ''}) async {
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '').trim();

    if (cleaned.startsWith('0')) {
      cleaned = '92${cleaned.substring(1)}';
    }
    if (cleaned.length <= 10) {
      cleaned = '92$cleaned';
    }

    final encodedMsg = Uri.encodeComponent(message);
    final url = message.isNotEmpty
        ? 'https://wa.me/$cleaned?text=$encodedMsg'
        : 'https://wa.me/$cleaned';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static bool isValidPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    return cleaned.length >= 5;
  }
}

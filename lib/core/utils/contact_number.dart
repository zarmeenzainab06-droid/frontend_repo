import 'package:url_launcher/url_launcher.dart';

class contactnumber {
  /// Opens WhatsApp chat for the given phone number.
  /// Automatically cleans and formats the number.
  static Future<void> openChat(String phone, {String message = ''}) async {
    // ── Clean the number ──────────────────────────────────────
    // Remove spaces, dashes, parentheses, plus signs
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '').trim();

    // If starts with 0 → assume Pakistani number → replace with 92
    if (cleaned.startsWith('0')) {
      cleaned = '92${cleaned.substring(1)}';
    }

    // If no country code (less than 11 digits) → add 92 (Pakistan)
    if (cleaned.length <= 10) {
      cleaned = '92$cleaned';
    }

    // ── Build WhatsApp URL ────────────────────────────────────
    final encodedMsg = Uri.encodeComponent(message);
    final urlString = message.isNotEmpty
        ? 'https://wa.me/$cleaned?text=$encodedMsg'
        : 'https://wa.me/$cleaned';

    final uri = Uri.parse(urlString);

    // ── Open URL ───────────────────────────────────────────────
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Checks if a phone number is valid enough to open WhatsApp
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    return cleaned.length >= 5; // at least 5 digits
  }
}

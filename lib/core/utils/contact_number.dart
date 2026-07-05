// lib/core/utils/contact_number.dart
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class contactnumber {
  /// Opens WhatsApp chat for the given phone number in a new browser tab.
  /// Automatically cleans and formats the number.
  static void openChat(String phone, {String message = ''}) {
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
    final url = message.isNotEmpty
        ? 'https://wa.me/$cleaned?text=$encodedMsg'
        : 'https://wa.me/$cleaned';

    // ── Open in new tab ───────────────────────────────────────
    html.window.open(url, '_blank');
  }

  /// Checks if a phone number is valid enough to open WhatsApp
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    return cleaned.length >= 5; // at least 5 digits
  }
}

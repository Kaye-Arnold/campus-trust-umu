/// Normalizes a Ugandan number for tel: and WhatsApp links.
/// Returns null when the value is not a plausible Ugandan mobile number.
String? normalizeUgandaPhone(String input) {
  var digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.startsWith('0')) digits = '256${digits.substring(1)}';
  if (!digits.startsWith('256')) return null;
  // Uganda mobile numbers are +256 followed by a 9-digit subscriber number.
  if (digits.length != 12 || !RegExp(r'^2567[0-9]{8}$').hasMatch(digits)) {
    return null;
  }
  return digits;
}

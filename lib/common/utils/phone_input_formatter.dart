import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  PhoneInputFormatter({
    required this.mask, // e.g. XXX-XXX-XXXX
    this.separator = '-',
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is empty, return it
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // If the user is deleting, allow it without forcing re-format immediately
    // unless they deleted a separator, in which case we might want to delete the digit before it too?
    // Simple approach: if length decreased, return newValue (allow deletion)
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    // Extract only digits from the new input
    String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // If no digits, return empty
    if (digits.isEmpty) return newValue;

    // Apply the mask
    final StringBuffer buffer = StringBuffer();
    int digitIndex = 0;

    for (int i = 0; i < mask.length; i++) {
      if (digitIndex >= digits.length) break;

      if (mask[i] == 'X') {
        buffer.write(digits[digitIndex]);
        digitIndex++;
      } else {
        buffer.write(mask[i]);
      }
    }

    // If the formatting extends beyond the digits entered (e.g. trailing separator), 
    // we should only include it if we haven't reached the end of the input digits?
    // Actually, normally we want to auto-append separators.
    // But if the mask char is not X, we appended it.
    
    // Corner case: If we have "123" and mask is "XXX-", loop runs 3 times for X, writes 123.
    // Then loop continues to '-'?
    // My loop condition `digitIndex >= digits.length` breaks immediately after last digit.
    // So if mask is `XXX-XXXX`, and I type `123`, output is `123`.
    // I want `123-`.
    
    // Proper logic:
    // If the next char in mask is a separator, and we just filled the previous slot?
    // Or just run the loop until `digitIndex` is exhausted, OR if we hit a separator right after the last digit?
    
    return _applyMask(digits);
  }

  TextEditingValue _applyMask(String digits) {
    final StringBuffer buffer = StringBuffer();
    int digitIndex = 0;
    
    for (int i = 0; i < mask.length; i++) {
      if (digitIndex >= digits.length) {
         break; 
      }
      
      if (mask[i] == 'X') {
        buffer.write(digits[digitIndex]);
        digitIndex++;
      } else {
        buffer.write(mask[i]);
        // If the separator is the last thing added and we seemingly ran out of digits, 
        // that's fine, we want to show it.
        // Wait, if I type '123' (mask XXX-), loop index 0(X): 1. index 1(X): 2. index 2(X): 3.
        // digitIndex becomes 3. digits.length is 3.
        // Loop index 3(-). mask[3] is '-'. Writes '-'.
        // Loop index 4(X). mask[4] is 'X'. digitIndex (3) >= digits.length (3). Break.
        // Result "123-". Correct.
      }
    }
    
    // Prevent buffer from ending with non-digit if we are strict?
    // Actually, usually beneficial to see the separator.
    
    String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

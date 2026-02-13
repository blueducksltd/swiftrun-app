// // ignore_for_file: file_names
//
// import 'package:flutter/services.dart';
//
// class NumberTextFormatter extends TextInputFormatter {
//   final int maxLength;
//
//   NumberTextFormatter({required this.maxLength});
//
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     final newTextLength = newValue.text.length;
//     final newText = StringBuffer();
//     var selectionIndex = newValue.selection.end;
//     var usedSubstringIndex = 0;
//
//     // Remove brackets
//     newValue = TextEditingValue(
//       text: newValue.text
//           .replaceAll('(', '')
//           .replaceAll(')', '')
//           .replaceAll('-', '')
//           .replaceAll(' ', ''),
//       selection: newValue.selection,
//     );
//
//     // ignore: unnecessary_null_comparison
//     if (maxLength != null && newTextLength > maxLength) {
//       // Trim the text if it exceeds the maximum length
//       newValue = TextEditingValue(
//         text: newValue.text.substring(0, maxLength),
//         selection: newValue.selection,
//       );
//     }
//
//     if (newTextLength >= 3) {
//       newText.write('${newValue.text.substring(0, usedSubstringIndex = 3)}-');
//       if (newValue.selection.end >= 3) selectionIndex++;
//     }
//     if (newTextLength >= 7) {
//       newText.write('${newValue.text.substring(3, usedSubstringIndex = 6)}-');
//       if (newValue.selection.end >= 6) selectionIndex++;
//     }
//     if (newTextLength >= 11) {
//       newText.write('${newValue.text.substring(6, usedSubstringIndex = 10)} ');
//       if (newValue.selection.end >= 10) selectionIndex++;
//     }
//     // Dump the rest.
//     if (newTextLength >= usedSubstringIndex) {
//       newText.write(newValue.text.substring(usedSubstringIndex));
//     }
//
//     return TextEditingValue(
//       text: newText.toString(),
//       selection: TextSelection.collapsed(offset: selectionIndex),
//     );
//   }
// }


// ignore_for_file: file_names

import 'package:flutter/services.dart';

class NumberTextFormatter extends TextInputFormatter {
  final int maxLength;

  NumberTextFormatter({required this.maxLength});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // Remove all formatting characters to get clean digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Return empty if no digits
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Limit to maxLength digits
    if (digitsOnly.length > maxLength) {
      digitsOnly = digitsOnly.substring(0, maxLength);
    }

    // Format the digits
    String formatted = _formatDigits(digitsOnly);

    // Calculate proper cursor position
    int cursorPosition = _calculateCursorPosition(
      oldValue.text,
      newValue.text,
      formatted,
      newValue.selection.baseOffset,
    );

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  String _formatDigits(String digits) {
    if (digits.length <= 3) {
      return digits;
    } else if (digits.length <= 6) {
      return '${digits.substring(0, 3)}-${digits.substring(3)}';
    } else {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
  }

  int _calculateCursorPosition(String oldText, String newText, String formattedText, int cursorPos) {
    // If user is deleting, handle cursor position carefully
    if (newText.length < oldText.length) {
      // Count digits before cursor in the new unformatted text
      String digitsOnly = newText.replaceAll(RegExp(r'[^0-9]'), '');
      int digitsBefore = 0;
      int pos = 0;

      // Count digits before cursor position in original text
      for (int i = 0; i < cursorPos && i < newText.length; i++) {
        if (RegExp(r'[0-9]').hasMatch(newText[i])) {
          digitsBefore++;
        }
      }

      // Find position in formatted text
      int formattedPos = 0;
      int digitsCount = 0;

      for (int i = 0; i < formattedText.length; i++) {
        if (RegExp(r'[0-9]').hasMatch(formattedText[i])) {
          digitsCount++;
          if (digitsCount > digitsBefore) {
            return i;
          }
        }
        formattedPos = i + 1;
      }

      return formattedPos;
    }

    // For insertion, place cursor at end
    return formattedText.length;
  }
}
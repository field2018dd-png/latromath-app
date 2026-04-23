import 'package:flutter/material.dart';

const kPrimary = Color(0xFFE8390E);
const kPrimaryLight = Color(0xFFFF5733);
const kPrimaryDark = Color(0xFFC0300A);
const kBackground = Color(0xFFF8F6F3);
const kCardBg = Colors.white;
const kTextDark = Color(0xFF1A1A1A);
const kTextGrey = Color(0xFF888888);

class AppTheme {
  static InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: kTextGrey, fontSize: 14),
      prefixIcon: Icon(icon, color: kPrimary, size: 20),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  static BoxDecoration cardDecoration({double radius = 20}) {
    return BoxDecoration(
      color: kCardBg,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 6),
        )
      ],
    );
  }
}
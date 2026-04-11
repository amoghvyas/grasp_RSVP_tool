import 'package:flutter/material.dart';

// ThemeProvider manages the visual theme state (Dark/Light mode).
class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = true;

  void toggle() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}

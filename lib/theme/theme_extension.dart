// for improving code readability
import 'package:flutter/material.dart';

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  // a SnackBar config for displaying err msgs
  SnackBar errorSnackBar(String errorMessage) => SnackBar(
    behavior: .floating,
    // feels right utilising empty space
    margin: .only(bottom: 200, left: 16, right: 16),
    backgroundColor: colorScheme.errorContainer,
    // feels right
    dismissDirection: .horizontal,
    persist: true, // stays
    content: Text(
      errorMessage,
      // feels right
      style: textTheme.labelMedium!.copyWith(
        color: colorScheme.onErrorContainer,
        fontWeight: .bold,
      ),
    ),
  );
}

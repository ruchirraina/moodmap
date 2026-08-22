import 'package:flutter/material.dart';

class AppAnimations {
  // Durations
  static const Duration fadeDuration = Duration(milliseconds: 600);
  static const Duration slideDuration = Duration(milliseconds: 400);
  static const Duration shakeDuration = Duration(milliseconds: 300);
  static const Duration animatedSizeDuration = Duration(milliseconds: 300);

  // Transition Scales
  static const double scaleBegin = 0.9;
  static const double scaleEnd = 1.0;

  // Transition Opacities
  static const double opacityBegin = 0.0;
  static const double opacityEnd = 1.0;

  // Transition Offsets
  static const Offset offsetZero = Offset.zero;
  static const Offset offsetLeft = Offset(-1.0, 0.0);
  static const Offset offsetRight = Offset(1.0, 0.0);

  // Shake Mechanics
  static const double shakeDistance = 4.0;
  static const double shakeSwingCount = 4.0;
}

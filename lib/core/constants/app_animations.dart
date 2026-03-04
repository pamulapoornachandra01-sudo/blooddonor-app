import 'package:flutter/material.dart';

class AppAnimations {
  AppAnimations._();

  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration page = Duration(milliseconds: 380);

  static const Curve curve = Curves.easeInOut;
  static const Curve enter = Curves.easeOutCubic;
}

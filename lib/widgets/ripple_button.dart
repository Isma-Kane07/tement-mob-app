// lib/widgets/ripple_button.dart
import 'package:flutter/material.dart';
import 'package:tement_mobile/config/theme.dart';

class RippleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color rippleColor;

  const RippleButton({
    super.key,
    required this.child,
    required this.onTap,
    this.rippleColor = TementColors.sunsetOrange,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: rippleColor.withOpacity(0.3),
        highlightColor: rippleColor.withOpacity(0.1),
        child: child,
      ),
    );
  }
}

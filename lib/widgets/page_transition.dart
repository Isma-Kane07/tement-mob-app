// lib/widgets/page_transition.dart
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class PageTransition extends StatelessWidget {
  final Widget child;

  const PageTransition({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedColor: Colors.transparent,
      closedElevation: 0,
      closedShape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      closedBuilder: (context, action) => child,
      openBuilder: (context, action) => child,
    );
  }
}

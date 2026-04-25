// lib/widgets/animated_background.dart
import 'package:flutter/material.dart';
import 'package:tement_mobile/config/theme.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                TementColors.lightBackground,
                Colors.white,
                TementColors.indigoTech.withOpacity(0.05),
                TementColors.sunsetOrange.withOpacity(0.05),
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // Cercles animés
              Positioned(
                left: -100 + _controller.value * 200,
                top: 50,
                child: _buildAnimatedCircle(
                    200, TementColors.indigoTech.withOpacity(0.1)),
              ),
              Positioned(
                right: -50 + _controller.value * 150,
                bottom: 100,
                child: _buildAnimatedCircle(
                    150, TementColors.sunsetOrange.withOpacity(0.1)),
              ),
              Positioned(
                left: 50 - _controller.value * 100,
                bottom: 200,
                child: _buildAnimatedCircle(
                    100, TementColors.softGold.withOpacity(0.1)),
              ),
              // Contenu
              widget.child,
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnimatedCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

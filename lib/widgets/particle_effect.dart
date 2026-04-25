// lib/widgets/particle_effect.dart
import 'package:flutter/material.dart';
import 'package:tement_mobile/config/theme.dart';

class ParticleEffect extends StatefulWidget {
  final Widget child;

  const ParticleEffect({super.key, required this.child});

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    for (int i = 0; i < 20; i++) {
      _particles.add(Particle());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(particles: _particles),
              size: MediaQuery.of(context).size,
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Particle {
  double x = (0.1 + (0.9 - 0.1) * (0.0 + 1.0) / 2.0);
  double y = 0.0;
  double size = 2.0 + (5.0 - 2.0) * (0.0 + 1.0) / 2.0;
  double speed = 0.5 + (2.0 - 0.5) * (0.0 + 1.0) / 2.0;
  Color color = TementColors.sunsetOrange
      .withOpacity(0.1 + (0.5 - 0.1) * (0.0 + 1.0) / 2.0);
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      paint.color = particle.color;
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );

      particle.y += particle.speed / size.height * 100;
      if (particle.y > 1.0) {
        particle.y = 0.0;
        particle.x = 0.1 + (0.9 - 0.1) * (0.0 + 1.0) / 2.0;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

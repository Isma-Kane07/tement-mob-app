// lib/widgets/particle_background.dart
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final Widget child;
  final int numberOfParticles;

  const ParticleBackground({
    super.key,
    required this.child,
    this.numberOfParticles = 30,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    // Initialiser les particules
    for (int i = 0; i < widget.numberOfParticles; i++) {
      _particles.add(Particle.random());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              painter: ParticlePainter(
                particles: _particles,
                progress: _controller.value,
              ),
              size: MediaQuery.of(context).size,
            );
          },
        ),
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speedX;
  double speedY;
  double opacity;

  Particle.random()
      : x = (0.1 + 0.8 * (0.0 + 1.0) / 2.0),
        y = (0.1 + 0.8 * (0.0 + 1.0) / 2.0),
        size = 1.0 + 3.0 * (0.0 + 1.0) / 2.0,
        speedX =
            (0.1 + 0.5 * (0.0 + 1.0) / 2.0) * (0.0 + 1.0) / 2.0 > 0.5 ? 1 : -1,
        speedY =
            (0.1 + 0.5 * (0.0 + 1.0) / 2.0) * (0.0 + 1.0) / 2.0 > 0.5 ? 1 : -1,
        opacity = 0.1 + 0.3 * (0.0 + 1.0) / 2.0;
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      // Mettre à jour la position
      particle.x += particle.speedX * 0.001;
      particle.y += particle.speedY * 0.001;

      // Rebondir sur les bords
      if (particle.x > 1.0 || particle.x < 0.0) {
        particle.speedX *= -1;
      }
      if (particle.y > 1.0 || particle.y < 0.0) {
        particle.speedY *= -1;
      }

      // Dessiner la particule
      paint.color = Colors.white.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

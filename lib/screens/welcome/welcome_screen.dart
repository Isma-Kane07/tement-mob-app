// lib/screens/welcome/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/screens/auth/login_screen.dart';
import 'package:tement_mobile/screens/auth/register_screen.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:tement_mobile/widgets/animated_background.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // ✅ Changé de SingleTickerProviderStateMixin à TickerProviderStateMixin

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideUpAnimation;
  late Animation<double> _scaleAnimation;

  final List<AnimationController> _featureControllers = [];
  final int _numberOfFeatures = 3;

  @override
  void initState() {
    super.initState();

    // Animation principale
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _slideUpAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutQuint),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Animations pour les fonctionnalités
    for (int i = 0; i < _numberOfFeatures; i++) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 600 + (i * 100)),
      );
      _featureControllers.add(controller);
    }

    _animationController.forward();

    // Lancer les animations des fonctionnalités en séquence
    Future.delayed(const Duration(milliseconds: 400), () {
      for (var controller in _featureControllers) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fond animé
          _buildAnimatedBackground(),

          // Particules décoratives
          _buildParticles(),

          // Contenu principal
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Logo animé
                        _buildAnimatedLogo(),

                        const SizedBox(height: 30),

                        // Titre animé
                        _buildAnimatedTitle(),

                        const SizedBox(height: 30),

                        // Badge premium
                        _buildPremiumBadge(),

                        const SizedBox(height: 40),

                        // Avantages premium
                        ...List.generate(
                          _numberOfFeatures,
                          (index) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildAnimatedFeature(index),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Boutons
                        _buildActionButtons(),

                        const SizedBox(height: 20),

                        // Footer
                        _buildFooter(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TementColors.indigoTech,
            TementColors.deepPurple,
            Color(0xFF0A0720),
          ],
          stops: [0.2, 0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildParticles() {
    return Stack(
      children: List.generate(20, (index) {
        final randomX = (index * 37) % 100 / 100;
        final randomY = (index * 73) % 100 / 100;
        final randomSize = 2.0 + (index % 5) * 2.0;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Positioned(
              left: MediaQuery.of(context).size.width * randomX,
              top: MediaQuery.of(context).size.height * randomY,
              child: Opacity(
                opacity: _fadeInAnimation.value * 0.3,
                child: Container(
                  width: randomSize,
                  height: randomSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TementColors.softGold.withOpacity(0.3),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildAnimatedLogo() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: const RadialGradient(
              colors: [
                TementColors.softGold,
                TementColors.sunsetOrange,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: TementColors.sunsetOrange.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'T',
              style: TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return Column(
      children: [
        SlideTransition(
          position: _slideUpAnimation,
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: const Text(
              'Bienvenue sur',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                letterSpacing: 1.5,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SlideTransition(
          position: _slideUpAnimation,
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  Colors.white,
                  TementColors.softGold,
                  TementColors.sunsetOrange,
                ],
                stops: [0.3, 0.7, 1.0],
              ).createShader(bounds),
              child: const Text(
                'TEMENT',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SlideTransition(
          position: _slideUpAnimation,
          child: FadeTransition(
            opacity: _fadeInAnimation,
            child: Container(
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    TementColors.sunsetOrange,
                    TementColors.softGold,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPremiumBadge() {
    return SlideTransition(
      position: _slideUpAnimation,
      child: FadeTransition(
        opacity: _fadeInAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                color: TementColors.softGold,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Location premium simplifiée',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedFeature(int index) {
    final List<Map<String, dynamic>> features = [
      {
        'icon': Icons.home_work_outlined,
        'title': 'Logements vérifiés',
        'subtitle': 'Des milliers de logements de qualité',
        'color': TementColors.softGold,
      },
      {
        'icon': Icons.payment_outlined,
        'title': 'Paiement sécurisé',
        'subtitle': 'Orange Money, Mobile Money',
        'color': TementColors.sunsetOrange,
      },
      {
        'icon': Icons.support_agent_outlined,
        'title': 'Support premium',
        'subtitle': 'Assistance 24h/24 et 7j/7',
        'color': Colors.white,
      },
    ];

    final feature = features[index];
    final controller = _featureControllers[index];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Opacity(
          opacity: controller.value,
          child: Transform.translate(
            offset: Offset(30 * (1 - controller.value), 0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              child: Row(
                children: [
                  // Icône avec animation au survol
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 200),
                      tween: Tween<double>(begin: 1.0, end: 1.0),
                      builder: (context, double scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  feature['color'].withOpacity(0.2),
                                  feature['color'].withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              feature['icon'],
                              color: feature['color'],
                              size: 30,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          feature['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          feature['subtitle'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Flèche indicative
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.3),
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Bouton SE CONNECTER avec animation
        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 600),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.easeOutQuint,
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: value,
                child: child,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                colors: [
                  TementColors.sunsetOrange,
                  TementColors.softGold,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: TementColors.sunsetOrange.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: CustomButton(
              text: 'SE CONNECTER',
              onPressed: () {
                HapticFeedback.heavyImpact();
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const LoginScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              backgroundColor: Colors.transparent,
              prefixIcon: Icons.login,
              height: 56,
              isFullWidth: true,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Bouton CRÉER UN COMPTE avec animation
        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 600),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.easeOutQuint,
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: value,
                child: child,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const RegisterScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                splashColor: TementColors.softGold.withOpacity(0.2),
                highlightColor: Colors.transparent,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add_alt_1,
                        color: TementColors.softGold,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'CRÉER UN COMPTE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: TementColors.softGold,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: Column(
        children: [
          Text(
            'En continuant, vous acceptez nos',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Conditions d\'utilisation',
                style: TextStyle(
                  fontSize: 12,
                  color: TementColors.softGold,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
              Text(
                ' et ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const Text(
                'Politique de confidentialité',
                style: TextStyle(
                  fontSize: 12,
                  color: TementColors.softGold,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

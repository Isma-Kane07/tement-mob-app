// lib/widgets/enhanced_logement_card.dart
import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/logement.dart';
import '../widgets/ripple_button.dart';
import '../utils/responsive_helper.dart';

class EnhancedLogementCard extends StatefulWidget {
  final Logement logement;
  final VoidCallback onTap;

  const EnhancedLogementCard({
    super.key,
    required this.logement,
    required this.onTap,
  });

  @override
  State<EnhancedLogementCard> createState() => _EnhancedLogementCardState();
}

class _EnhancedLogementCardState extends State<EnhancedLogementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final bool _isHovered = false;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return AnimatedScale(
      scale: _scaleAnimation.value,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () {
          _animationController.forward().then((_) {
            _animationController.reverse();
            widget.onTap();
          });
        },
        child: Card(
          elevation: _isHovered ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image avec overlay
              _buildImageSection(),

              // Contenu
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.logement.adresse,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildTypeChip(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildOwnerInfo(),
                    const SizedBox(height: 12),
                    _buildPriceAndAction(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: widget.logement.photos.isEmpty
                ? Container(
                    color: TementColors.greySecondary.withOpacity(0.1),
                    child: const Icon(
                      Icons.image,
                      size: 40,
                      color: TementColors.greySecondary,
                    ),
                  )
                : PageView.builder(
                    itemCount: widget.logement.photos.length,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return Image.network(
                        widget.logement.photos[index],
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: TementColors.greySecondary.withOpacity(0.1),
                          child: const Icon(
                            Icons.broken_image,
                            color: TementColors.greySecondary,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),

        // Overlay gradient
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Indicateur de position
        if (widget.logement.photos.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.logement.photos.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? TementColors.sunsetOrange
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),

        // Badge de disponibilité
        if (!widget.logement.disponible)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Complet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // Compteur d'images
        if (widget.logement.photos.isNotEmpty)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_camera,
                    size: 12,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_currentImageIndex + 1}/${widget.logement.photos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: TementColors.softGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.logement.type == 'maison'
                ? Icons.home
                : widget.logement.type == 'appartement'
                    ? Icons.apartment
                    : Icons.room_service,
            size: 12,
            color: TementColors.softGold,
          ),
          const SizedBox(width: 4),
          Text(
            widget.logement.typeEnFrancais,
            style: const TextStyle(
              color: TementColors.softGold,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: TementColors.greySecondary.withOpacity(0.2),
          backgroundImage: widget.logement.proprietaire?.photoUrl != null
              ? NetworkImage(widget.logement.proprietaire!.photoUrl!)
              : null,
          child: widget.logement.proprietaire?.photoUrl == null
              ? const Icon(Icons.person, size: 12)
              : null,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            widget.logement.proprietaire?.nom ?? 'Propriétaire',
            style: const TextStyle(
              fontSize: 12,
              color: TementColors.greySecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceAndAction() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'À partir de',
              style: TextStyle(
                fontSize: 11,
                color: TementColors.greySecondary,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.logement.formattedPrix,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: TementColors.indigoTech,
                  ),
                ),
                const Text(
                  ' /nuit',
                  style: TextStyle(
                    fontSize: 11,
                    color: TementColors.greySecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            color: TementColors.sunsetOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: RippleButton(
            onTap: widget.onTap,
            rippleColor: TementColors.sunsetOrange,
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Réserver',
                    style: TextStyle(
                      color: TementColors.sunsetOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: TementColors.sunsetOrange,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

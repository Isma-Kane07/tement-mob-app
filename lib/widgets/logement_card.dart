// lib/widgets/logement_card.dart
import 'package:flutter/material.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/models/logement.dart';
import 'package:tement_mobile/config/constants.dart';

class LogementCard extends StatefulWidget {
  final Logement logement;
  final VoidCallback onTap;

  const LogementCard({
    super.key,
    required this.logement,
    required this.onTap,
  });

  @override
  State<LogementCard> createState() => _LogementCardState();
}

class _LogementCardState extends State<LogementCard>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentImageIndex = 0;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String getImageUrl(int index) {
    if (widget.logement.photos.isNotEmpty &&
        index < widget.logement.photos.length) {
      final photo = widget.logement.photos[index];
      if (photo.startsWith('http')) {
        return photo;
      }
      return '${ApiConstants.baseUrl}/uploads/$photo';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final hasMultiplePhotos = widget.logement.photos.length > 1;
    final proprietaire = widget.logement.proprietaire;

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.identity()..scale(_isHovered ? 1.02 : 1.0),
            child: Card(
              elevation: _isHovered ? 8 : 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: TementColors.indigoTech.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section image avec overlay
                  _buildImageSection(hasMultiplePhotos),

                  // Contenu
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Adresse et type
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
                        const SizedBox(height: 12),

                        // Propriétaire
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  TementColors.greySecondary.withOpacity(0.2),
                              backgroundImage: proprietaire?.photoUrl != null
                                  ? NetworkImage(proprietaire!.photoUrl!)
                                  : null,
                              child: proprietaire?.photoUrl == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: TementColors.greySecondary,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                proprietaire?.nom ?? 'Propriétaire',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: TementColors.greySecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Prix et bouton
                        Row(
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
                                      '${widget.logement.prixNuit.toStringAsFixed(0)} FCFA',
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
                            _buildReserveButton(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(bool hasMultiplePhotos) {
    return Stack(
      children: [
        // Image principale ou carousel
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
                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 40,
                        color: TementColors.greySecondary,
                      ),
                    ),
                  )
                : PageView.builder(
                    controller: _pageController,
                    itemCount: widget.logement.photos.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final imageUrl = getImageUrl(index);
                      return Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: TementColors.greySecondary.withOpacity(0.1),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 40,
                              color: TementColors.greySecondary,
                            ),
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
        if (hasMultiplePhotos)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.logement.photos.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: _currentImageIndex == index ? 20 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentImageIndex == index
                        ? TementColors.sunsetOrange
                        : Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),
          ),

        // Compteur d'images
        if (widget.logement.photos.isNotEmpty)
          Positioned(
            top: 12,
            left: 12,
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Badge indisponible
        if (!widget.logement.disponible)
          Positioned(
            top: 12,
            left: 12,
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
                'Indisponible',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeChip() {
    IconData icon;
    switch (widget.logement.type) {
      case 'maison':
        icon = Icons.home;
        break;
      case 'appartement':
        icon = Icons.apartment;
        break;
      case 'studio':
        icon = Icons.room_service;
        break;
      default:
        icon = Icons.house;
    }

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
            icon,
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

  Widget _buildReserveButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(30),
        splashColor: TementColors.sunsetOrange.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: TementColors.sunsetOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Row(
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
    );
  }
}

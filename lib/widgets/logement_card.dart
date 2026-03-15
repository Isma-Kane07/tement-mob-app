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

class _LogementCardState extends State<LogementCard> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

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
    final proprietaireNom = widget.logement.proprietaire?.nom ?? 'Propriétaire';
    final hasMultiplePhotos = widget.logement.photos.length > 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ GALLERIE D'IMAGES
            Stack(
              children: [
                Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: widget.logement.photos.isEmpty
                      ? Container(
                          color: TementColors.greySecondary.withOpacity(0.1),
                          child: Center(
                            child: Icon(
                              Icons.image,
                              size: 50,
                              color:
                                  TementColors.greySecondary.withOpacity(0.3),
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
                                color:
                                    TementColors.greySecondary.withOpacity(0.1),
                                child: Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: TementColors.greySecondary
                                        .withOpacity(0.5),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Indicateur de position (points)
                if (hasMultiplePhotos)
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        widget.logement.photos.length,
                        (index) => Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
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

                // Compteur d'images
                if (widget.logement.photos.isNotEmpty)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.photo,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_currentImageIndex + 1}/${widget.logement.photos.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
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
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
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
            ),

            // Informations
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.logement.adresse,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: TementColors.softGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.logement.typeEnFrancais,
                          style: const TextStyle(
                            color: TementColors.softGold,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 16,
                        color: TementColors.greySecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          proprietaireNom,
                          style: const TextStyle(
                            color: TementColors.greySecondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ BOUTON VOIR À LA PLACE DES AVIS
                      OutlinedButton.icon(
                        onPressed: widget.onTap,
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Réserver'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: TementColors.indigoTech,
                          side: BorderSide(
                            color: TementColors.indigoTech.withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            widget.logement.formattedPrix,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: TementColors.indigoTech,
                            ),
                          ),
                          const Text(
                            ' /nuit',
                            style: TextStyle(
                              color: TementColors.greySecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

// lib/widgets/reservation_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/models/reservation.dart';
import 'package:flutter/services.dart';

class ReservationCard extends StatefulWidget {
  final Reservation reservation;
  final VoidCallback onTap;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
  });

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');
    final logement = widget.reservation.logement;

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
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
          _animationController.forward(from: 0.0);
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: _isExpanded ? 8 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Ligne principale
                  Row(
                    children: [
                      // Image
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: TementColors.greySecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          image: logement?.photos.isNotEmpty ?? false
                              ? DecorationImage(
                                  image: NetworkImage(logement!.photos.first),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: logement?.photos.isEmpty ?? true
                            ? const Icon(
                                Icons.image,
                                color: TementColors.greySecondary,
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),

                      // Infos
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Adresse
                            Text(
                              logement?.adresse ?? 'Adresse inconnue',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Dates
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 12,
                                  color: TementColors.greySecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${dateFormat.format(widget.reservation.dateDebut)} - ${dateFormat.format(widget.reservation.dateFin)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: TementColors.greySecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            // Montant
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${widget.reservation.montantTotal.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TementColors.indigoTech,
                                    fontSize: 16,
                                  ),
                                ),
                                _buildStatusChip(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Détails expandables
                  SizeTransition(
                    axisAlignment: -1.0,
                    sizeFactor: CurvedAnimation(
                      parent: _animationController,
                      curve: Curves.easeOut,
                    ),
                    child: Column(
                      children: [
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildDetailItem(
                              icon: Icons.nights_stay,
                              label: 'Nuits',
                              value: '${widget.reservation.nombreNuits}',
                            ),
                            _buildDetailItem(
                              icon: Icons.person,
                              label: 'Locataire',
                              value:
                                  widget.reservation.locataire?.nom ?? 'Vous',
                            ),
                            _buildDetailItem(
                              icon: Icons.verified,
                              label: 'Réservation',
                              value: '#${widget.reservation.id}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Indicateur de détails
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isExpanded ? 0.5 : 0.0,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: TementColors.greySecondary,
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

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: widget.reservation.statutCouleur.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.reservation.statutCouleur.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.reservation.statutCouleur,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.reservation.statutEnFrancais,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: widget.reservation.statutCouleur,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TementColors.indigoTech.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 16,
            color: TementColors.indigoTech,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: TementColors.greySecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: TementColors.indigoTech,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/models/reservation.dart';
import 'package:intl/intl.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onTap;

  const ReservationCard({
    super.key,
    required this.reservation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: TementColors.greySecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image,
                  color: TementColors.greySecondary,
                ),
              ),
              const SizedBox(width: 12),

              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.logement?.adresse ?? 'Adresse inconnue',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dateFormat.format(reservation.dateDebut)} → ${dateFormat.format(reservation.dateFin)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: TementColors.greySecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${reservation.nombreNuits} nuits',
                          style: const TextStyle(fontSize: 12),
                        ),

                        // ✅ BADGE DE STATUT UNIQUE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: reservation.statutCouleur.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            reservation.statutEnFrancais,
                            style: TextStyle(
                              fontSize: 10,
                              color: reservation.statutCouleur,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${reservation.montantTotal.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TementColors.indigoTech,
                          ),
                        ),

                        // ✅ PLUS DE BADGE "PAIEMENT REQUIS" SÉPARÉ
                        // Le statut est déjà affiché dans le badge ci-dessus
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

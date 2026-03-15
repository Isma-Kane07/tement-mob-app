import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/models/reservation.dart';
import 'package:tement_mobile/providers/auth_provider.dart';
import 'package:tement_mobile/providers/reservation_provider.dart';
import 'package:tement_mobile/screens/paiements/soumettre_paiement_screen.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class DetailReservationScreen extends StatefulWidget {
  final Reservation reservation;

  const DetailReservationScreen({super.key, required this.reservation});

  @override
  State<DetailReservationScreen> createState() =>
      _DetailReservationScreenState();
}

class _DetailReservationScreenState extends State<DetailReservationScreen> {
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');
  bool _isLoading = false;

  Future<void> _confirmerReservation() async {
    setState(() => _isLoading = true);

    try {
      final reservationProvider =
          Provider.of<ReservationProvider>(context, listen: false);

      final success =
          await reservationProvider.confirmerReservation(widget.reservation.id);

      if (success && mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await reservationProvider.loadReservations(authProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Réservation confirmée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                reservationProvider.error ?? 'Erreur lors de la confirmation'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _annulerReservation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content:
            const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final reservationProvider =
          Provider.of<ReservationProvider>(context, listen: false);

      final success =
          await reservationProvider.annulerReservation(widget.reservation.id);

      if (success && mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await reservationProvider.loadReservations(authProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réservation annulée'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final reservation = widget.reservation;
    final isLocataire = user?.id == reservation.locataireId;
    final isProprietaire = user?.id == reservation.logement?.proprietaireId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la réservation'),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Traitement en cours...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statut
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: reservation.statutCouleur.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatutIcon(reservation.statut),
                            color: reservation.statutCouleur,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            reservation.statutEnFrancais,
                            style: TextStyle(
                              color: reservation.statutCouleur,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Carte du logement
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Logement',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color:
                                      TementColors.indigoTech.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.home_outlined,
                                  color: TementColors.indigoTech,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      reservation.logement?.adresse ??
                                          'Adresse inconnue',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      reservation.logement?.typeEnFrancais ??
                                          '',
                                      style: TextStyle(
                                        color: TementColors.greySecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Détails de la réservation
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Détails du séjour',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Arrivée',
                            _dateFormat.format(reservation.dateDebut),
                            Icons.login,
                          ),
                          _buildInfoRow(
                            'Départ',
                            _dateFormat.format(reservation.dateFin),
                            Icons.logout,
                          ),
                          _buildInfoRow(
                            'Nombre de nuits',
                            '${reservation.nombreNuits} nuits',
                            Icons.nights_stay,
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Montant total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${reservation.montantTotal.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: TementColors.indigoTech,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Informations sur le propriétaire/locataire
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLocataire ? 'Propriétaire' : 'Locataire',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: TementColors.indigoTech,
                                child: Text(
                                  (isLocataire
                                          ? reservation
                                              .logement?.proprietaire?.nom[0]
                                          : reservation.locataire?.nom[0]) ??
                                      '?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isLocataire
                                        ? reservation
                                                .logement?.proprietaire?.nom ??
                                            'Inconnu'
                                        : reservation.locataire?.nom ??
                                            'Inconnu',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    isLocataire ? 'Propriétaire' : 'Locataire',
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
                  ),
                  const SizedBox(height: 24),

                  // ✅ BOUTONS D'ACTION AVEC ELSE IF

                  // 1. PRIORITÉ MAX : Paiement effectué (pour tous)
                  if (reservation.statut == 'paye') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.purple.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLocataire
                                      ? '✅ Paiement confirmé'
                                      : '💰 Paiement reçu',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isLocataire
                                      ? 'Votre paiement a été validé. Votre réservation est confirmée.'
                                      : 'Le montant de ${reservation.montantTotal.toStringAsFixed(0)} FCFA a été crédité sur votre wallet.',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]

                  // 2. Propriétaire : Confirmer une réservation en attente
                  else if (isProprietaire &&
                      reservation.statut == 'en_attente') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Cette réservation attend votre confirmation',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: '✅ Confirmer la réservation',
                            onAsyncPressed: _confirmerReservation,
                            backgroundColor: Colors.green,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: _annulerReservation,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Refuser la réservation'),
                          ),
                        ],
                      ),
                    ),
                  ]

                  // 3. Locataire : Payer après confirmation
                  else if (isLocataire && reservation.statut == 'confirme') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.green.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '✅ Réservation confirmée !',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Le propriétaire a confirmé votre réservation. '
                            'Vous devez maintenant effectuer le paiement pour finaliser.',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: '💰 Procéder au paiement',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SoumettrePaiementScreen(
                                    reservationId: reservation.id,
                                    montantTotal: reservation.montantTotal,
                                    logementAdresse:
                                        reservation.logement?.adresse ??
                                            'Adresse inconnue',
                                  ),
                                ),
                              );
                            },
                            backgroundColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ]

                  // 4. Propriétaire : En attente de paiement
                  else if (isProprietaire &&
                      reservation.statut == 'confirme') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.hourglass_empty,
                              color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'En attente du paiement du locataire',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Bouton d'annulation pour le locataire (si toujours possible)
                  if (isLocataire &&
                      (reservation.statut == 'en_attente' ||
                          reservation.statut == 'confirme')) ...[
                    Center(
                      child: TextButton(
                        onPressed: _annulerReservation,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Annuler la réservation'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: TementColors.greySecondary),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(color: TementColors.greySecondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatutIcon(String statut) {
    switch (statut) {
      case 'en_attente':
        return Icons.hourglass_empty;
      case 'confirme':
        return Icons.check_circle_outline;
      case 'paye':
        return Icons.payment;
      case 'annule':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

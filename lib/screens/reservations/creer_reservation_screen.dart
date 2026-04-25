// lib/screens/reservations/creer_reservation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/models/logement.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:tement_mobile/providers/reservation_provider.dart';
import 'package:intl/intl.dart';

class CreerReservationScreen extends StatefulWidget {
  final Logement logement;

  const CreerReservationScreen({super.key, required this.logement});

  @override
  State<CreerReservationScreen> createState() => _CreerReservationScreenState();
}

class _CreerReservationScreenState extends State<CreerReservationScreen> {
  DateTime? _dateDebut;
  DateTime? _dateFin;
  int _nombreNuits = 0;
  double _montantTotal = 0;
  bool _isLoading = false;

  final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    final logement = widget.logement;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Confirmer la réservation',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white, // ✅ Texte blanc
          ),
        ),
        backgroundColor: TementColors.indigoTech, // ✅ Fond indigo visible
        elevation: 0,
        foregroundColor: Colors.white, // ✅ Icône retour blanche
        iconTheme: const IconThemeData(
          color: Colors.white, // ✅ Icône retour blanche
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: TementColors.indigoTech.withOpacity(0.1),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          TementColors.sunsetOrange), // ✅ COULEUR UNIQUE
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Création de votre réservation...',
                    style: TextStyle(
                      fontSize: 16,
                      color: TementColors.greySecondary,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte du logement premium
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          TementColors.lightBackground,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: TementColors.indigoTech.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Image placeholder avec gradient
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  TementColors.indigoTech,
                                  TementColors.deepPurple,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.home_outlined,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Infos
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  logement.typeEnFrancais,
                                  style: const TextStyle(
                                    color: TementColors.greySecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  logement.adresse,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: TementColors.sunsetOrange
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${logement.prixNuit.toStringAsFixed(0)} FCFA',
                                        style: const TextStyle(
                                          color: TementColors.sunsetOrange,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'par nuit',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: TementColors.greySecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Titre section dates
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: TementColors.indigoTech.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          color: TementColors.indigoTech,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Dates du séjour',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  TementColors.indigoTech, // ✅ AJOUTER COULEUR
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sélecteurs de dates premium
                  _buildDateSelector(
                    isDebut: true,
                    date: _dateDebut,
                    label: "Arrivée",
                    icon: Icons.flight_land,
                  ),
                  const SizedBox(height: 12),
                  _buildDateSelector(
                    isDebut: false,
                    date: _dateFin,
                    label: "Départ",
                    icon: Icons.flight_takeoff,
                  ),

                  if (_dateDebut != null && _dateFin != null) ...[
                    const SizedBox(height: 24),

                    // Résumé du séjour
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            TementColors.indigoTech.withOpacity(0.05),
                            TementColors.deepPurple.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Ligne durée
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.nights_stay,
                                      color: TementColors.sunsetOrange,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Durée du séjour',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: TementColors.indigoTech
                                            .withOpacity(0.1),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '$_nombreNuits ${_nombreNuits > 1 ? 'nuits' : 'nuit'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: TementColors.indigoTech,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const SizedBox(height: 16),

                            // Détail du prix
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$_nombreNuits × ${logement.prixNuit.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                Text(
                                  '${_montantTotal.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Total
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: TementColors.sunsetOrange
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total à payer',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${_montantTotal.toStringAsFixed(0)} FCFA',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: TementColors.sunsetOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // ✅ BOUTON AVEC COULEUR UNIQUE (Sunset Orange)
                  CustomButton(
                    text: 'Confirmer la réservation',
                    onAsyncPressed: _dateDebut != null &&
                            _dateFin != null &&
                            _nombreNuits > 0
                        ? _handleReservation
                        : null,
                    isLoading: _isLoading,
                    backgroundColor:
                        TementColors.sunsetOrange, // ✅ COULEUR UNIQUE
                    isFullWidth: true,
                    height: 56,
                  ),

                  const SizedBox(height: 16),

                  // Message d'info
                  const Center(
                    child: Text(
                      'Vous ne serez pas débité maintenant',
                      style: TextStyle(
                        color: TementColors.greySecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDateSelector({
    required bool isDebut,
    required DateTime? date,
    required String label,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectDate(isDebut),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: date != null
                  ? TementColors.indigoTech.withOpacity(0.3)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: date != null
                      ? TementColors.indigoTech.withOpacity(0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: date != null
                      ? TementColors.indigoTech
                      : TementColors.greySecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TementColors.greySecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date == null
                          ? 'Sélectionner une date'
                          : _displayFormat.format(date),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: date != null ? FontWeight.w600 : null,
                        color: date != null
                            ? TementColors.indigoTech
                            : TementColors.greySecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: date != null
                    ? TementColors.indigoTech
                    : TementColors.greySecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isDebut) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: TementColors.sunsetOrange,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: TementColors.indigoTech,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isDebut) {
          _dateDebut = picked;
          if (_dateFin != null && _dateFin!.isBefore(_dateDebut!)) {
            _dateFin = null;
            _nombreNuits = 0;
            _montantTotal = 0;
          }
        } else {
          if (_dateDebut != null && picked.isAfter(_dateDebut!)) {
            _dateFin = picked;
          } else if (_dateDebut != null) {
            _showErrorSnackBar(
              'La date de départ doit être après la date d\'arrivée',
            );
            return;
          } else {
            _dateFin = picked;
          }
        }
        _calculerPrix();
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _calculerPrix() {
    if (_dateDebut != null && _dateFin != null) {
      _nombreNuits = _dateFin!.difference(_dateDebut!).inDays;
      _montantTotal = _nombreNuits * widget.logement.prixNuit;
    }
  }

  Future<void> _handleReservation() async {
    setState(() => _isLoading = true);

    try {
      final reservationProvider =
          Provider.of<ReservationProvider>(context, listen: false);

      final success = await reservationProvider.creerReservation(
        logementId: widget.logement.id,
        dateDebut: _dateDebut!,
        dateFin: _dateFin!,
      );

      if (success && mounted) {
        _showSuccessDialog();
      } else if (mounted) {
        _showErrorSnackBar(
          reservationProvider.error ?? 'Erreur lors de la réservation',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                TementColors.lightBackground,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Colors.green.shade400,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Réservation créée !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_nombreNuits nuits',
                style: const TextStyle(
                  color: TementColors.indigoTech,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_montantTotal.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  color: TementColors.sunsetOrange,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: TementColors.indigoTech.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'En attente de confirmation du propriétaire',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Voir mes réservations',
                onPressed: () {
                  Navigator.pop(context); // Fermer dialogue
                  Navigator.pop(context); // Retour au détail
                  Navigator.pop(context); // Retour à la liste
                },
                backgroundColor: TementColors.indigoTech, // ✅ COULEUR UNIQUE
              ),
            ],
          ),
        ),
      ),
    );
  }
}

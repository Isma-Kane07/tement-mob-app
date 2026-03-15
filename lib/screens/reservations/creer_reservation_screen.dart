import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/models/logement.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:tement_mobile/widgets/custom_input.dart';
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
      appBar: AppBar(
        title: const Text('Réserver'),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Création de la réservation...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé du logement
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TementColors.lightBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: TementColors.indigoTech.withOpacity(0.1),
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
                                logement.adresse,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${logement.prixNuit.toStringAsFixed(0)} FCFA / nuit',
                                style: const TextStyle(
                                  color: TementColors.indigoTech,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sélection des dates
                  Text(
                    'Dates du séjour',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),

                  // Date de début
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TementColors.indigoTech.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: TementColors.indigoTech,
                        size: 20,
                      ),
                    ),
                    title: const Text("Date d'arrivée"),
                    subtitle: Text(
                      _dateDebut == null
                          ? 'Sélectionner une date'
                          : _displayFormat.format(_dateDebut!),
                      style: TextStyle(
                        color: _dateDebut == null
                            ? TementColors.greySecondary
                            : null,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _selectDate(true),
                  ),

                  // Date de fin
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: TementColors.indigoTech.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today,
                        color: TementColors.indigoTech,
                        size: 20,
                      ),
                    ),
                    title: const Text('Date de départ'),
                    subtitle: Text(
                      _dateFin == null
                          ? 'Sélectionner une date'
                          : _displayFormat.format(_dateFin!),
                      style: TextStyle(
                        color: _dateFin == null
                            ? TementColors.greySecondary
                            : null,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _selectDate(false),
                  ),

                  if (_dateDebut != null && _dateFin != null) ...[
                    const SizedBox(height: 24),

                    // Récapitulatif des prix
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TementColors.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_nombreNuits nuits × ${logement.prixNuit.toStringAsFixed(0)} FCFA',
                              ),
                              Text('${_montantTotal.toStringAsFixed(0)} FCFA'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${_montantTotal.toStringAsFixed(0)} FCFA',
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
                  ],

                  const SizedBox(height: 32),

                  // Bouton de réservation
                  // Bouton de réservation
                  CustomButton(
                    text: 'Confirmer la réservation',
                    onAsyncPressed: (_dateDebut != null &&
                            _dateFin != null &&
                            _nombreNuits > 0)
                        ? _handleReservation
                        : null, // ✅ Utilise onAsyncPressed au lieu de onPressed
                    isLoading: _isLoading,
                  ),
                ],
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'La date de départ doit être après la date d\'arrivée'),
                backgroundColor: Colors.orange,
              ),
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
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Réservation créée !'),
            content: Text(
              'Votre réservation pour $_nombreNuits nuits a été enregistrée.\n'
              'Montant total: ${_montantTotal.toStringAsFixed(0)} FCFA\n\n'
              'En attente de confirmation du propriétaire.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fermer dialogue
                  Navigator.pop(context); // Retour au détail
                  Navigator.pop(context); // Retour à la liste
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                reservationProvider.error ?? 'Erreur lors de la réservation'),
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
}

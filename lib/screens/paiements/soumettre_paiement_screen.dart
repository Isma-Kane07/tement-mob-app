import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/widgets/custom_input.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:tement_mobile/services/paiement_service.dart';

class SoumettrePaiementScreen extends StatefulWidget {
  final int reservationId;
  final double montantTotal;
  final String logementAdresse;

  const SoumettrePaiementScreen({
    super.key,
    required this.reservationId,
    required this.montantTotal,
    required this.logementAdresse,
  });

  @override
  State<SoumettrePaiementScreen> createState() =>
      _SoumettrePaiementScreenState();
}

class _SoumettrePaiementScreenState extends State<SoumettrePaiementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  String _selectedMethode = 'orange_money';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _methodesPaiement = [
    {
      'value': 'orange_money',
      'label': 'Orange Money',
      'icon': Icons.phone_android,
      'color': Colors.orange,
    },
    {
      'value': 'moov_money',
      'label': 'Moov Money',
      'icon': Icons.phone_android,
      'color': Colors.blue,
    },
    {
      'value': 'mtn_money',
      'label': 'MTN Money',
      'icon': Icons.phone_android,
      'color': Colors.yellow,
    },
  ];

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final paiementService = PaiementService();

        await paiementService.soumettrePaiement(
          reservationId: widget.reservationId,
          methode: _selectedMethode,
          referenceTransaction: _referenceController.text,
        );

        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Paiement soumis !'),
              content: const Text(
                'Votre paiement a été enregistré. Il sera validé par nos équipes sous 24h.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fermer dialogue
                    Navigator.pop(context); // Retour au détail
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
      ),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Traitement du paiement...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Récapitulatif
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TementColors.lightBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Récapitulatif',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            'Logement',
                            widget.logementAdresse,
                            Icons.home_outlined,
                          ),
                          _buildInfoRow(
                            'Montant à payer',
                            '${widget.montantTotal.toStringAsFixed(0)} FCFA',
                            Icons.payments_outlined,
                            isBold: true,
                            color: TementColors.indigoTech,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: TementColors.softGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: TementColors.softGold.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: TementColors.softGold,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Comment payer ?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: TementColors.softGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '1. Effectuez le virement sur notre compte Orange Money\n'
                            '📱 Compte Tement: 78 90 12 34\n'
                            '💰 Montant: À renseigner\n\n'
                            '2. Entrez la référence de la transaction\n'
                            '3. Soumettez votre paiement\n\n'
                            '⏱️ Votre paiement sera validé sous 24h',
                            style: TextStyle(fontSize: 13, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Méthode
                    Text(
                      'Méthode de paiement',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ..._methodesPaiement.map((m) => _buildMethodeTile(m)),
                    const SizedBox(height: 16),

                    // Référence
                    CustomInput(
                      controller: _referenceController,
                      label: 'Référence de transaction',
                      prefixIcon: Icons.receipt_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La référence est requise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Bouton
                    CustomButton(
                      text: 'Soumettre le paiement',
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon,
      {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: TementColors.greySecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(color: TementColors.greySecondary, fontSize: 14),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color,
                fontSize: 14,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodeTile(Map<String, dynamic> methode) {
    final isSelected = _selectedMethode == methode['value'];

    return RadioListTile<String>(
      value: methode['value'],
      groupValue: _selectedMethode,
      onChanged: (value) {
        setState(() {
          _selectedMethode = value!;
        });
      },
      title: Row(
        children: [
          Icon(methode['icon'], color: methode['color']),
          const SizedBox(width: 8),
          Text(methode['label']),
        ],
      ),
      activeColor: TementColors.indigoTech,
    );
  }
}

// lib/screens/paiements/soumettre_paiement_screen.dart
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

class _SoumettrePaiementScreenState extends State<SoumettrePaiementScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  String _selectedMethode = 'orange_money';
  bool _isSubmitting = false;
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _methodesPaiement = [
    {
      'value': 'orange_money',
      'label': 'Orange Money',
      'icon': Icons.phone_android,
      'color': Colors.orange,
      'numero': '82 74 94 38',
    },
    {
      'value': 'moov_money',
      'label': 'Moov Money',
      'icon': Icons.phone_android,
      'color': Colors.green,
      'numero': '66 56 63 76',
    },
    {
      'value': 'mtn_money',
      'label': 'WAVE',
      'icon': Icons.phone_android,
      'color': Colors.blue,
      'numero': '82 74 94 38',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _animationController.dispose();
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
          _showSuccessDialog();
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar(e.toString());
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
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
              // Animation de succès
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 500),
                tween: Tween<double>(begin: 0, end: 1),
                curve: Curves.elasticOut,
                builder: (context, double scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade200,
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Colors.green.shade400,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Paiement soumis !',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Montant: ${widget.montantTotal.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  fontSize: 18,
                  color: TementColors.indigoTech,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TementColors.indigoTech.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Text(
                      '⏱️ En attente de validation',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Votre paiement sera validé sous 24h',
                      style: TextStyle(
                        fontSize: 13,
                        color: TementColors.greySecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Voir mes réservations',
                onPressed: () {
                  Navigator.pop(context); // Fermer dialogue
                  Navigator.pop(context); // Retour au détail
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message.replaceAll('Exception: ', ''))),
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

  @override
  Widget build(BuildContext context) {
    final methodeSelectionnee = _methodesPaiement.firstWhere(
      (m) => m['value'] == _selectedMethode,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      // Dans le build method, remplacer l'appBar par :

      appBar: AppBar(
        title: const Text(
          'Paiement sécurisé',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white, // ✅ Texte BLANC
          ),
        ),
        backgroundColor: TementColors.indigoTech, // ✅ Fond BLEU
        elevation: 0,
        foregroundColor: Colors.white,
        iconTheme:
            const IconThemeData(color: Colors.white), // ✅ Icône retour blanche
      ),
      body: _isSubmitting
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
                    child: const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Traitement du paiement...',
                    style: TextStyle(
                      fontSize: 16,
                      color: TementColors.greySecondary,
                    ),
                  ),
                ],
              ),
            )
          : FadeTransition(
              opacity: _animationController,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Récapitulatif premium
                      _buildRecapitulatifCard(),

                      const SizedBox(height: 24),

                      // Instructions de paiement
                      _buildInstructionsCard(methodeSelectionnee),

                      const SizedBox(height: 24),

                      // Sélection méthode
                      _buildMethodesSection(),

                      const SizedBox(height: 24),

                      // Référence transaction
                      _buildReferenceSection(),

                      const SizedBox(height: 32),

                      // Bouton de soumission
                      _buildSubmitButton(),

                      const SizedBox(height: 16),

                      // Message de sécurité
                      _buildSecurityMessage(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildRecapitulatifCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            TementColors.lightBackground,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TementColors.indigoTech.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_outlined,
                    color: TementColors.indigoTech,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Récapitulatif',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              icon: Icons.home_outlined,
              label: 'Logement',
              value: widget.logementAdresse,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        TementColors.sunsetOrange,
                        TementColors.softGold,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.montantTotal.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard(Map<String, dynamic> methode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            TementColors.softGold.withOpacity(0.1),
            TementColors.sunsetOrange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: TementColors.softGold.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: TementColors.softGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Comment payer ?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStepNumber(1, 'Effectuez le virement'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: TementColors.softGold.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.phone_android,
                  color: methode['color'],
                  size: 30,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        methode['label'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Compte: ${methode['numero']}',
                        style: const TextStyle(
                          color: TementColors.indigoTech,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStepNumber(2, 'Entrez la référence'),
          const Padding(
            padding: EdgeInsets.only(left: 32, top: 8),
            child: Text(
              'La référence SMS reçue après votre paiement',
              style: TextStyle(
                fontSize: 13,
                color: TementColors.greySecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildStepNumber(3, 'Soumettez votre paiement'),
        ],
      ),
    );
  }

  Widget _buildStepNumber(int number, String text) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: TementColors.sunsetOrange,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMethodesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de paiement',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        ..._methodesPaiement.map((m) => _buildMethodeCard(m)),
      ],
    );
  }

  Widget _buildMethodeCard(Map<String, dynamic> methode) {
    final isSelected = _selectedMethode == methode['value'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethode = methode['value'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? methode['color'] : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: methode['color'].withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: methode['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                methode['icon'],
                color: methode['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    methode['label'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Compte: ${methode['numero']}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: TementColors.greySecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: methode['color'],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Référence de transaction',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        CustomInput(
          controller: _referenceController,
          label: 'Référence SMS',
          hintText: 'Ex: 78901234',
          prefixIcon: Icons.receipt_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La référence est requise';
            }
            if (value.length < 8) {
              return 'Référence invalide (minimum 8 caractères)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [
            TementColors.sunsetOrange,
            TementColors.softGold,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: TementColors.sunsetOrange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CustomButton(
        text: 'Soumettre le paiement',
        onPressed: _handleSubmit,
        backgroundColor: Colors.transparent,
        isFullWidth: true,
        height: 56,
      ),
    );
  }

  Widget _buildSecurityMessage() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_outline,
          size: 14,
          color: TementColors.greySecondary,
        ),
        SizedBox(width: 4),
        Text(
          'Paiement sécurisé - Validation d\'ici 1h',
          style: TextStyle(
            fontSize: 11,
            color: TementColors.greySecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: TementColors.greySecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label:',
              style: const TextStyle(color: TementColors.greySecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

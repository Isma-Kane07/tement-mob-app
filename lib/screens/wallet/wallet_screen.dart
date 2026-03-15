import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/auth_provider.dart';
import 'package:tement_mobile/services/retrait_service.dart';
import 'package:tement_mobile/models/retrait.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final RetraitService _retraitService = RetraitService();
  List<Retrait> _retraits = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadHistorique();
  }

  Future<void> _loadHistorique() async {
    setState(() => _isLoading = true);

    try {
      final retraits = await _retraitService.getHistoriqueRetraits();
      setState(() {
        _retraits = retraits;
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('Erreur de chargement: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _demanderRetrait(double montant) async {
    setState(() => _isSubmitting = true);

    try {
      final retrait = await _retraitService.demanderRetrait(
        montant: montant,
        methodeRetrait: 'orange_money',
      );

      if (mounted) {
        await _loadHistorique();

        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final nouveauSolde = (authProvider.user?.walletBalance ?? 0) - montant;
        authProvider.updateWalletBalance(nouveauSolde);

        _showSuccessSnackbar('✅ Demande de retrait envoyée avec succès');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('❌ Erreur: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showRetraitModal() {
    final TextEditingController montantController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône de fermeture
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        foregroundColor: TementColors.greySecondary,
                      ),
                    ),
                  ),

                  // Icône principale
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: TementColors.indigoTech.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 40,
                      color: TementColors.indigoTech,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Titre
                  Text(
                    'Demande de retrait',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Retirez vos gains vers votre compte',
                    style: TextStyle(
                      color: TementColors.greySecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Solde disponible
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TementColors.indigoTech.withOpacity(0.1),
                          TementColors.deepPurple.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Solde disponible',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${Provider.of<AuthProvider>(context).user?.walletBalance.toStringAsFixed(0)} FCFA',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: TementColors.indigoTech,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Champ montant
                  TextFormField(
                    controller: montantController,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Montant à retirer',
                      hintText: 'Ex: 25000',
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: TementColors.indigoTech,
                          width: 2,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un montant';
                      }
                      final montant = double.tryParse(value);
                      if (montant == null) {
                        return 'Montant invalide';
                      }
                      if (montant < 1000) {
                        return 'Le montant minimum est de 1 000 FCFA';
                      }
                      final solde =
                          Provider.of<AuthProvider>(context, listen: false)
                                  .user
                                  ?.walletBalance ??
                              0;
                      if (montant > solde) {
                        return 'Solde insuffisant';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Délai de traitement
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.blue.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Délai de traitement',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Votre retrait sera traité sous 24h maximum',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Boutons d'action
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Annuler'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final montant =
                                  double.parse(montantController.text);
                              Navigator.pop(context);
                              _demanderRetrait(montant);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TementColors.sunsetOrange,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Confirmer'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Calcul des statistiques
    double totalRetraits = 0;
    double enAttente = 0;
    double totalRevenus = user?.walletBalance ?? 0;

    for (var retrait in _retraits) {
      if (retrait.statut == 'valide') {
        totalRetraits += retrait.montant;
        totalRevenus += retrait.montant;
      } else if (retrait.statut == 'en_attente') {
        enAttente += retrait.montant;
      }
    }

    return Scaffold(
      backgroundColor: TementColors.lightBackground,
      appBar: AppBar(
        title: const Text('Mon Wallet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: TementColors.indigoTech,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistorique,
          ),
        ],
      ),
      body: _isSubmitting
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Traitement de la demande...'),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadHistorique,
              color: TementColors.sunsetOrange,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Carte de solde principale
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            TementColors.indigoTech,
                            TementColors.deepPurple,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: TementColors.indigoTech.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Colors.white70,
                                size: 24,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Solde disponible',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${user?.walletBalance.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Statistiques rapides
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Total gagné',
                                  '${totalRevenus.toStringAsFixed(0)} FCFA',
                                  Icons.trending_up,
                                  Colors.green,
                                  light: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Total retiré',
                                  '${totalRetraits.toStringAsFixed(0)} FCFA',
                                  Icons.trending_down,
                                  Colors.red,
                                  light: true,
                                ),
                              ),
                            ],
                          ),
                          if (enAttente > 0) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.hourglass_empty,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Retrait en attente: ${enAttente.toStringAsFixed(0)} FCFA',
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),

                          // Bouton de retrait
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _showRetraitModal,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: TementColors.indigoTech,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.payments),
                                  SizedBox(width: 8),
                                  Text(
                                    'Effectuer un retrait',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section historique
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: TementColors.indigoTech.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: TementColors.indigoTech,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Historique des retraits',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                        if (_retraits.isNotEmpty)
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: TementColors.indigoTech,
                            ),
                            child: const Text('Voir tout'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Liste des retraits
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_retraits.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history_outlined,
                              size: 80,
                              color:
                                  TementColors.greySecondary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun retrait pour le moment',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vos demandes de retrait apparaîtront ici',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: TementColors.greySecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ..._retraits
                          .map((retrait) => _buildRetraitTile(retrait))
                          .toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    bool light = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: light ? Colors.white.withOpacity(0.15) : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: light ? Colors.white : color,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: light ? Colors.white70 : TementColors.greySecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: light ? Colors.white : color,
              fontWeight: FontWeight.bold,
              fontSize: light ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetraitTile(Retrait retrait) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icône de statut
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: retrait.statutCouleur.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                retrait.statut == 'valide'
                    ? Icons.check_circle
                    : retrait.statut == 'refuse'
                        ? Icons.cancel
                        : Icons.hourglass_empty,
                color: retrait.statutCouleur,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Détails
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${retrait.montant.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (retrait.createdAt != null)
                    Text(
                      dateFormat.format(retrait.createdAt!),
                      style: TextStyle(
                        fontSize: 12,
                        color: TementColors.greySecondary,
                      ),
                    ),
                  if (retrait.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      retrait.description!,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Badge de statut
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: retrait.statutCouleur.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                retrait.statutEnFrancais,
                style: TextStyle(
                  fontSize: 12,
                  color: retrait.statutCouleur,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

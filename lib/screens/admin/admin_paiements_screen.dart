// lib/screens/admin/admin_paiements_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/admin_provider.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class AdminPaiementsScreen extends StatefulWidget {
  const AdminPaiementsScreen({super.key});

  @override
  State<AdminPaiementsScreen> createState() => _AdminPaiementsScreenState();
}

class _AdminPaiementsScreenState extends State<AdminPaiementsScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false)
          .loadPaiementsEnAttente();
    });
  }

  Future<void> _validerPaiement(int paiementId) async {
    final confirm = await _showConfirmDialog(
      title: 'Valider le paiement',
      message: 'Êtes-vous sûr de vouloir valider ce paiement ?',
      confirmText: 'Valider',
    );

    if (confirm != true) return;

    final provider = Provider.of<AdminProvider>(context, listen: false);
    final success = await provider.validerPaiement(paiementId);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Paiement validé avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur lors de la validation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Paiements en attente',
          style: TextStyle(
              fontWeight: FontWeight.w600, color: TementColors.indigoTech),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.paiementsEnAttente.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.paiementsEnAttente.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Aucun paiement en attente',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadPaiementsEnAttente(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.paiementsEnAttente.length,
              itemBuilder: (context, index) {
                final paiement = provider.paiementsEnAttente[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                paiement['methode'] ?? 'Paiement',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              '${paiement['montant_total']} FCFA',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: TementColors.indigoTech,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          'Référence',
                          paiement['reference'] ?? 'N/A',
                        ),
                        _buildInfoRow(
                          'Locataire',
                          paiement['locataire']?['nom'] ?? 'Inconnu',
                        ),
                        _buildInfoRow(
                          'Logement',
                          paiement['logement']?['adresse'] ?? 'Inconnu',
                        ),
                        _buildInfoRow(
                          'Dates',
                          '${paiement['reservation']?['dates']?['debut']} → ${paiement['reservation']?['dates']?['fin']}',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Valider',
                                onPressed: () =>
                                    _validerPaiement(paiement['id']),
                                backgroundColor: Colors.green,
                                isFullWidth: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: TementColors.greySecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

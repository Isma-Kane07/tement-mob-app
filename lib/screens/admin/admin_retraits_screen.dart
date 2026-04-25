// lib/screens/admin/admin_retraits_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/admin_provider.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:intl/intl.dart';

class AdminRetraitsScreen extends StatefulWidget {
  const AdminRetraitsScreen({super.key});

  @override
  State<AdminRetraitsScreen> createState() => _AdminRetraitsScreenState();
}

class _AdminRetraitsScreenState extends State<AdminRetraitsScreen> {
  final TextEditingController _referenceController = TextEditingController();
  int? _selectedRetraitId;
  String? _raisonRefus;
  bool _isProcessing = false;

  final DateFormat _dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false)
          .loadRetraitsEnAttente();
    });
  }

  Future<void> _validerRetrait(int retraitId) async {
    final confirm = await _showConfirmDialog(
      title: 'Valider le retrait',
      message: 'Confirmez-vous le virement ?',
      confirmText: 'Valider',
      isConfirm: true,
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    final provider = Provider.of<AdminProvider>(context, listen: false);
    final success =
        await provider.validerRetrait(retraitId, _referenceController.text);

    setState(() => _isProcessing = false);

    if (success && mounted) {
      _referenceController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Retrait validé avec succès'),
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

  Future<void> _refuserRetrait(int retraitId) async {
    final confirm = await _showConfirmDialog(
      title: 'Refuser le retrait',
      message: 'Êtes-vous sûr de vouloir refuser ce retrait ?',
      confirmText: 'Refuser',
      isConfirm: false,
    );

    if (confirm != true) return;

    final provider = Provider.of<AdminProvider>(context, listen: false);
    final success =
        await provider.refuserRetrait(retraitId, _raisonRefus ?? '');

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Retrait refusé'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required bool isConfirm,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (!isConfirm) ...[
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Raison du refus (optionnel)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => _raisonRefus = value,
              ),
            ],
            if (isConfirm) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _referenceController,
                decoration: const InputDecoration(
                  hintText: 'Référence de virement',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isConfirm ? Colors.green : Colors.red,
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
          'Retraits en attente',
          style: TextStyle(
              fontWeight: FontWeight.w600, color: TementColors.indigoTech),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.retraitsEnAttente.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.retraitsEnAttente.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 80, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'Aucune demande de retrait',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadRetraitsEnAttente(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.retraitsEnAttente.length,
              itemBuilder: (context, index) {
                final retrait = provider.retraitsEnAttente[index];
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
                            Text(
                              retrait['proprietaire']['nom'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
                                '${retrait['montant']} FCFA',
                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Téléphone',
                          retrait['proprietaire']['telephone'] ?? 'N/A',
                        ),
                        _buildInfoRow(
                          'Date demande',
                          _dateFormat
                              .format(DateTime.parse(retrait['date_demande'])),
                        ),
                        _buildInfoRow(
                          'Solde avant',
                          '${retrait['solde_avant']} FCFA',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                text: 'Valider',
                                onPressed: _isProcessing
                                    ? null
                                    : () => _validerRetrait(retrait['id']),
                                backgroundColor: Colors.green,
                                isFullWidth: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: CustomButton(
                                text: 'Refuser',
                                onPressed: _isProcessing
                                    ? null
                                    : () => _refuserRetrait(retrait['id']),
                                backgroundColor: Colors.red,
                                isOutlined: true,
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
      padding: const EdgeInsets.only(bottom: 6),
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
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

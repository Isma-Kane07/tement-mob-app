// lib/screens/admin/admin_transactions_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/admin_provider.dart';
import 'package:intl/intl.dart';

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() =>
      _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy HH:mm', 'fr_FR');
  String _selectedType = 'all';

  final List<Map<String, String>> _typeOptions = [
    {'value': 'all', 'label': 'Toutes'},
    {'value': 'revenu_location', 'label': 'Revenus location'},
    {'value': 'commission', 'label': 'Commissions'},
    {'value': 'retrait', 'label': 'Retraits'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(
              fontWeight: FontWeight.w600, color: TementColors.indigoTech),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Filtres
              _buildFilters(provider),

              // Stats simplifiées
              _buildSimpleStats(provider),

              // Liste des transactions
              Expanded(
                child: provider.transactions.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_outlined,
                                size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Aucune transaction',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.loadTransactions(
                            type:
                                _selectedType == 'all' ? null : _selectedType),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = provider.transactions[index];
                            return _buildTransactionCard(transaction);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(AdminProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _typeOptions.map((type) {
            final isSelected = _selectedType == type['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(type['label']!),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedType = selected ? type['value']! : 'all';
                  });
                  provider.loadTransactions(
                    type: _selectedType == 'all' ? null : _selectedType,
                  );
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: TementColors.indigoTech.withOpacity(0.1),
                labelStyle: TextStyle(
                  color: isSelected
                      ? TementColors.indigoTech
                      : TementColors.greySecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ✅ STATS SIMPLIFIÉES (sans transactionsStats)
  Widget _buildSimpleStats(AdminProvider provider) {
    // Calculer les stats à partir des transactions
    double totalGeneral = 0;
    double totalRevenus = 0;
    double totalCommissions = 0;
    double totalRetraits = 0;

    for (var transaction in provider.transactions) {
      final montant = (transaction['montant'] ?? 0).toDouble();
      final type = transaction['type'] ?? '';
      final statut = transaction['statut'] ?? '';

      if (statut == 'valide') {
        totalGeneral += montant;
        if (type == 'revenu_location') {
          totalRevenus += montant;
        } else if (type == 'commission') {
          totalCommissions += montant;
        } else if (type == 'retrait') {
          totalRetraits += montant;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TementColors.indigoTech,
            TementColors.deepPurple,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total général',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              Text(
                '${totalGeneral.toStringAsFixed(0)} FCFA',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (totalRevenus > 0)
                _buildStatChip(
                  label: 'Revenus',
                  montant: totalRevenus,
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
              if (totalCommissions > 0)
                _buildStatChip(
                  label: 'Commissions',
                  montant: totalCommissions,
                  icon: Icons.percent,
                  color: TementColors.sunsetOrange,
                ),
              if (totalRetraits > 0)
                _buildStatChip(
                  label: 'Retraits',
                  montant: totalRetraits,
                  icon: Icons.money_off,
                  color: Colors.red,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required double montant,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            '$label: ${montant.toStringAsFixed(0)} FCFA',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    final type = transaction['type'];
    final statut = transaction['statut'];
    final montant = transaction['montant'];
    final user = transaction['Utilisateur'];
    final createdAt = DateTime.parse(transaction['createdAt']);

    IconData icon;
    Color color;
    String label;

    switch (type) {
      case 'revenu_location':
        icon = Icons.trending_up;
        color = Colors.green;
        label = 'Revenu location';
        break;
      case 'commission':
        icon = Icons.percent;
        color = TementColors.sunsetOrange;
        label = 'Commission';
        break;
      case 'retrait':
        icon = Icons.money_off;
        color = Colors.red;
        label = 'Retrait';
        break;
      default:
        icon = Icons.receipt;
        color = Colors.grey;
        label = type;
    }

    Color statutColor;
    String statutLabel;
    IconData statutIcon;

    switch (statut) {
      case 'valide':
        statutColor = Colors.green;
        statutLabel = 'Validé';
        statutIcon = Icons.check_circle;
        break;
      case 'en_attente':
        statutColor = Colors.orange;
        statutLabel = 'En attente';
        statutIcon = Icons.hourglass_empty;
        break;
      case 'refuse':
        statutColor = Colors.red;
        statutLabel = 'Refusé';
        statutIcon = Icons.cancel;
        break;
      default:
        statutColor = Colors.grey;
        statutLabel = statut;
        statutIcon = Icons.info;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?['nom'] ?? 'Utilisateur inconnu',
                        style: const TextStyle(
                          fontSize: 12,
                          color: TementColors.greySecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${montant.toStringAsFixed(0)} FCFA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statutColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statutIcon, color: statutColor, size: 10),
                          const SizedBox(width: 4),
                          Text(
                            statutLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: statutColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              transaction['description'] ?? 'Aucune description',
              style: const TextStyle(
                  fontSize: 12, color: TementColors.greySecondary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 12, color: TementColors.greySecondary),
                const SizedBox(width: 4),
                Text(
                  _dateFormat.format(createdAt),
                  style: const TextStyle(
                      fontSize: 11, color: TementColors.greySecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

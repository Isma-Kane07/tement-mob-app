// lib/screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/admin_provider.dart';
import 'package:tement_mobile/widgets/custom_button.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(
              fontWeight: FontWeight.w600, color: TementColors.indigoTech),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: TementColors.indigoTech,
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'Réessayer',
                    onPressed: () => provider.loadDashboard(),
                    width: 200,
                  ),
                ],
              ),
            );
          }

          final dashboard = provider.dashboard;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Section Paiements
                _buildSectionTitle('💰 Paiements'),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Commissions totales',
                        value:
                            '${dashboard?['paiements']['totalCommission'] ?? 0} FCFA',
                        icon: Icons.trending_up,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Revenus totaux',
                        value:
                            '${dashboard?['paiements']['totalRevenus'] ?? 0} FCFA',
                        icon: Icons.account_balance,
                        color: TementColors.indigoTech,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Paiements en attente',
                        value:
                            '${dashboard?['paiements']['paiementsEnAttente'] ?? 0}',
                        icon: Icons.hourglass_empty,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'CA Mensuel',
                        value:
                            '${dashboard?['paiements']['caMensuel'] ?? 0} FCFA',
                        icon: Icons.calendar_month,
                        color: TementColors.sunsetOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section Utilisateurs
                _buildSectionTitle('👥 Utilisateurs'),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total utilisateurs',
                        value: '${dashboard?['utilisateurs']['total'] ?? 0}',
                        icon: Icons.people,
                        color: TementColors.indigoTech,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Propriétaires',
                        value:
                            '${dashboard?['utilisateurs']['proprietaires'] ?? 0}',
                        icon: Icons.home,
                        color: TementColors.softGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Locataires',
                        value:
                            '${dashboard?['utilisateurs']['locataires'] ?? 0}',
                        icon: Icons.person,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Logements',
                        value: '${dashboard?['logements']['total'] ?? 0}',
                        icon: Icons.apartment,
                        color: TementColors.deepPurple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Section Réservations
                _buildSectionTitle('📅 Réservations'),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Confirmées',
                        value:
                            '${dashboard?['reservations']['confirmees'] ?? 0}',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'En attente',
                        value:
                            '${dashboard?['reservations']['enAttente'] ?? 0}',
                        icon: Icons.hourglass_empty,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildStatCard(
                  title: 'Retraits en attente',
                  value: '${dashboard?['retraits']['enAttente'] ?? 0}',
                  icon: Icons.money_off,
                  color: Colors.red,
                ),

                const SizedBox(height: 24),

                // Boutons d'action rapide
                _buildSectionTitle('⚡ Actions rapides'),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        title: 'Paiements',
                        icon: Icons.payment,
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/paiements'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        title: 'Retraits',
                        icon: Icons.money_off,
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/retraits'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        title: 'Utilisateurs',
                        icon: Icons.people,
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/utilisateurs'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        title: 'Commissions',
                        icon: Icons.trending_up,
                        onTap: () =>
                            Navigator.pushNamed(context, '/admin/commissions'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: TementColors.indigoTech,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: TementColors.greySecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: TementColors.indigoTech.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: TementColors.indigoTech, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: TementColors.indigoTech,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

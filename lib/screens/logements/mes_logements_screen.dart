import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/auth_provider.dart';
import 'package:tement_mobile/providers/logement_provider.dart';
import 'package:tement_mobile/models/logement.dart';
import 'package:tement_mobile/widgets/logement_card.dart';
import 'package:tement_mobile/screens/logements/detail_logement_screen.dart';
import 'package:tement_mobile/screens/logements/modifier_logement_screen.dart';
import 'package:tement_mobile/screens/logements/ajouter_logement_screen.dart';

class MesLogementsScreen extends StatefulWidget {
  const MesLogementsScreen({super.key});

  @override
  State<MesLogementsScreen> createState() => _MesLogementsScreenState();
}

class _MesLogementsScreenState extends State<MesLogementsScreen> {
  @override
  void initState() {
    super.initState();
    _loadMesLogements();
  }

  Future<void> _loadMesLogements() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      await Provider.of<LogementProvider>(context, listen: false)
          .loadMesLogements(user.id);
    }
  }

  Future<void> _toggleDisponibilite(Logement logement) async {
    final logementProvider =
        Provider.of<LogementProvider>(context, listen: false);

    final success = await logementProvider.toggleDisponibilite(
        logement.id, !logement.disponible);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            logement.disponible
                ? '🔴 Logement désactivé'
                : '🟢 Logement activé',
          ),
          backgroundColor: logement.disponible ? Colors.orange : Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _showDeleteConfirmation(Logement logement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le logement'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer le logement à "${logement.adresse}" ?\n\nCette action est irréversible.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final logementProvider =
                  Provider.of<LogementProvider>(context, listen: false);

              final success =
                  await logementProvider.deleteLogement(logement.id);

              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Logement supprimé avec succès'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes logements'),
        backgroundColor: TementColors.indigoTech,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMesLogements,
            tooltip: 'Rafraîchir',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AjouterLogementScreen(),
                ),
              ).then((_) => _loadMesLogements());
            },
            tooltip: 'Ajouter un logement',
          ),
        ],
      ),
      body: Consumer<LogementProvider>(
        builder: (context, logementProvider, child) {
          // État de chargement
          if (logementProvider.isLoading &&
              logementProvider.mesLogements.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement de vos logements...'),
                ],
              ),
            );
          }

          // État d'erreur
          if (logementProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 60,
                        color: Colors.red.shade300,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Oups ! Une erreur est survenue',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      logementProvider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadMesLogements,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TementColors.sunsetOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Liste vide
          if (logementProvider.mesLogements.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: TementColors.indigoTech.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.home_outlined,
                        size: 80,
                        color: TementColors.indigoTech.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Vous n\'avez pas encore de logement',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Commencez par ajouter votre premier logement à louer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TementColors.greySecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AjouterLogementScreen(),
                          ),
                        ).then((_) => _loadMesLogements());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter un logement'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TementColors.sunsetOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Liste des logements
          return RefreshIndicator(
            onRefresh: _loadMesLogements,
            color: TementColors.sunsetOrange,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: logementProvider.mesLogements.length,
              itemBuilder: (context, index) {
                final logement = logementProvider.mesLogements[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Badge de statut en haut à droite
                        Stack(
                          children: [
                            LogementCard(
                              logement: logement,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailLogementScreen(
                                      logement: logement,
                                    ),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: logement.disponible
                                      ? Colors.green
                                      : Colors.orange,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (logement.disponible
                                              ? Colors.green
                                              : Colors.orange)
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      logement.disponible
                                          ? Icons.check_circle
                                          : Icons.visibility_off,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      logement.disponible
                                          ? 'Disponible'
                                          : 'Indisponible',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Barre d'actions
                        Container(
                          decoration: BoxDecoration(
                            color: TementColors.lightBackground,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                icon: logement.disponible
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                label: logement.disponible
                                    ? 'Désactiver'
                                    : 'Activer',
                                color: logement.disponible
                                    ? Colors.orange
                                    : Colors.green,
                                onTap: () => _toggleDisponibilite(logement),
                              ),
                              Container(
                                height: 30,
                                width: 1,
                                color:
                                    TementColors.greySecondary.withOpacity(0.3),
                              ),
                              _buildActionButton(
                                icon: Icons.edit,
                                label: 'Modifier',
                                color: TementColors.indigoTech,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ModifierLogementScreen(
                                        logement: logement,
                                      ),
                                    ),
                                  ).then((_) => _loadMesLogements());
                                },
                              ),
                              Container(
                                height: 30,
                                width: 1,
                                color:
                                    TementColors.greySecondary.withOpacity(0.3),
                              ),
                              _buildActionButton(
                                icon: Icons.delete_outline,
                                label: 'Supprimer',
                                color: Colors.red,
                                onTap: () => _showDeleteConfirmation(logement),
                              ),
                            ],
                          ),
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

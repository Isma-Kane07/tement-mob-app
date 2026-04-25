// lib/screens/admin/admin_utilisateurs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/admin_provider.dart';

class AdminUtilisateursScreen extends StatefulWidget {
  const AdminUtilisateursScreen({super.key});

  @override
  State<AdminUtilisateursScreen> createState() =>
      _AdminUtilisateursScreenState();
}

class _AdminUtilisateursScreenState extends State<AdminUtilisateursScreen> {
  String _searchQuery = '';
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false).loadUtilisateurs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Utilisateurs',
          style: TextStyle(
              fontWeight: FontWeight.w600, color: TementColors.indigoTech),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
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
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un utilisateur...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                  Provider.of<AdminProvider>(context, listen: false)
                      .loadUtilisateurs(search: value);
                },
              ),
            ),
          ),

          // Filtre par rôle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('Tous', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Locataires', 'locataire'),
                const SizedBox(width: 8),
                _buildFilterChip('Propriétaires', 'proprietaire'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Liste des utilisateurs
          Expanded(
            child: Consumer<AdminProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.utilisateurs.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.utilisateurs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Aucun utilisateur trouvé',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadUtilisateurs(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: provider.utilisateurs.length,
                    itemBuilder: (context, index) {
                      final user = provider.utilisateurs[index];
                      return _buildUserCard(user);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedRole == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedRole = value);
        Provider.of<AdminProvider>(context, listen: false)
            .loadUtilisateurs(role: value == 'all' ? null : value);
      },
      backgroundColor: Colors.white,
      selectedColor: TementColors.indigoTech.withOpacity(0.1),
      checkmarkColor: TementColors.indigoTech,
      labelStyle: TextStyle(
        color:
            isSelected ? TementColors.indigoTech : TementColors.greySecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final isProprietaire = user['role'] == 'proprietaire';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isProprietaire
              ? TementColors.softGold.withOpacity(0.2)
              : TementColors.indigoTech.withOpacity(0.2),
          child: Icon(
            isProprietaire ? Icons.home : Icons.person,
            color: isProprietaire
                ? TementColors.softGold
                : TementColors.indigoTech,
          ),
        ),
        title: Text(
          user['nom'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['telephone']),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (user['role'] == 'proprietaire'
                        ? TementColors.softGold
                        : TementColors.indigoTech)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user['role'] == 'proprietaire' ? 'Propriétaire' : 'Locataire',
                style: TextStyle(
                  fontSize: 10,
                  color: user['role'] == 'proprietaire'
                      ? TementColors.softGold
                      : TementColors.indigoTech,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isProprietaire)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TementColors.sunsetOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${user['wallet_balance'] ?? 0} FCFA',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: TementColors.sunsetOrange,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: () {
                // Naviguer vers le détail de l'utilisateur
              },
            ),
          ],
        ),
      ),
    );
  }
}

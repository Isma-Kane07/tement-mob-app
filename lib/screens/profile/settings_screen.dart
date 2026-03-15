import 'package:flutter/material.dart';
import 'package:tement_mobile/config/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Français';
  String _currency = 'FCFA';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications
          _buildSectionTitle('Notifications'),
          _buildSwitchTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications push',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Apparence
          _buildSectionTitle('Apparence'),
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            title: 'Mode sombre',
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
          ),

          const SizedBox(height: 16),

          // Langue
          _buildSectionTitle('Langue'),
          _buildRadioTile<String>(
            value: 'Français',
            groupValue: _selectedLanguage,
            title: 'Français',
            subtitle: 'Langue par défaut',
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),
          _buildRadioTile<String>(
            value: 'Anglais',
            groupValue: _selectedLanguage,
            title: 'Anglais',
            subtitle: 'English',
            onChanged: (value) {
              setState(() {
                _selectedLanguage = value!;
              });
            },
          ),

          const SizedBox(height: 16),

          // Devise
          _buildSectionTitle('Devise'),
          _buildRadioTile<String>(
            value: 'FCFA',
            groupValue: _currency,
            title: 'Franc CFA',
            subtitle: 'XOF',
            onChanged: (value) {
              setState(() {
                _currency = value!;
              });
            },
          ),
          _buildRadioTile<String>(
            value: 'Euro',
            groupValue: _currency,
            title: 'Euro',
            subtitle: 'EUR',
            onChanged: (value) {
              setState(() {
                _currency = value!;
              });
            },
          ),

          const SizedBox(height: 24),

          // Options supplémentaires
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined,
                      color: TementColors.indigoTech),
                  title: const Text('Confidentialité'),
                  subtitle: const Text('Gérer vos données'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.security_outlined,
                      color: TementColors.indigoTech),
                  title: const Text('Sécurité'),
                  subtitle: const Text('Mot de passe, authentification'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.info_outlined,
                      color: TementColors.indigoTech),
                  title: const Text('À propos'),
                  subtitle: const Text('Version 1.0.0'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bouton de sauvegarde
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paramètres enregistrés'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TementColors.sunsetOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Enregistrer',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: TementColors.greySecondary,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TementColors.indigoTech.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: TementColors.indigoTech),
        ),
        title: Text(title),
        value: value,
        onChanged: onChanged,
        activeColor: TementColors.sunsetOrange,
      ),
    );
  }

  Widget _buildRadioTile<T>({
    required T value,
    required T groupValue,
    required String title,
    required String subtitle,
    required ValueChanged<T?> onChanged,
  }) {
    return Card(
      child: RadioListTile<T>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        title: Text(title),
        subtitle: Text(subtitle),
        activeColor: TementColors.sunsetOrange,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TementColors.indigoTech.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            value == 'Français' || value == 'FCFA'
                ? Icons.language
                : Icons.euro,
            color: TementColors.indigoTech,
          ),
        ),
      ),
    );
  }
}

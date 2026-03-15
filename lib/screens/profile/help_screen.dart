import 'package:flutter/material.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ
            const Text(
              'Questions fréquentes',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqTile(
              'Comment effectuer une réservation ?',
              'Sélectionnez un logement, choisissez vos dates et confirmez. Le propriétaire devra valider votre demande.',
            ),
            _buildFaqTile(
              'Comment payer ?',
              'Après confirmation du propriétaire, vous pouvez payer par Orange Money. Suivez les instructions dans l\'application.',
            ),
            _buildFaqTile(
              'Comment sont calculées les commissions ?',
              'Tement prélève une commission de 15% sur chaque réservation.',
            ),
            _buildFaqTile(
              'Comment retirer mon argent ?',
              'En tant que propriétaire, vous pouvez demander un retrait depuis votre wallet. Le transfert se fait sous 24-48h.',
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),

            // Contact
            const Text(
              'Nous contacter',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              icon: Icons.phone_outlined,
              title: 'Service client',
              value: '78 90 12 34',
              color: Colors.green,
              onTap: () => _launchPhone('78901234'),
            ),

            _buildContactCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: 'support@tement.com',
              color: Colors.blue,
              onTap: () => _launchEmail('support@tement.com'),
            ),

            _buildContactCard(
              icon: Icons.language_outlined,
              title: 'Site web',
              value: 'www.tement.com',
              color: TementColors.indigoTech,
              onTap: () => _launchUrl('https://www.tement.com'),
            ),

            _buildContactCard(
              icon: Icons.facebook_outlined,
              title: 'Facebook',
              value: '@tement.officiel',
              color: const Color(0xFF1877F2),
              onTap: () => _launchUrl('https://facebook.com/tement'),
            ),

            const SizedBox(height: 32),

            // Horaires
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TementColors.lightBackground,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.access_time, color: TementColors.indigoTech),
                      SizedBox(width: 8),
                      Text(
                        'Horaires d\'ouverture',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildHourRow('Lundi - Vendredi', '08h00 - 18h00'),
                  _buildHourRow('Samedi', '09h00 - 13h00'),
                  _buildHourRow('Dimanche', 'Fermé'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: const Icon(Icons.help_outline, color: TementColors.indigoTech),
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(color: TementColors.greySecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.open_in_new, size: 20),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHourRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(hours, style: TextStyle(color: TementColors.greySecondary)),
        ],
      ),
    );
  }
}

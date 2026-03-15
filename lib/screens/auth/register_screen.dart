import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/config/constants.dart';
import 'package:tement_mobile/providers/auth_provider.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:tement_mobile/widgets/custom_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'locataire'; // Par défaut
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.signup(
        nom: _nomController.text,
        telephone: _telephoneController.text,
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(authProvider.error ?? 'Erreur lors de l\'inscription'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Créer un compte',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Rejoignez la communauté Tement',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),

              // Formulaire
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Nom
                    CustomInput(
                      controller: _nomController,
                      label: 'Nom complet',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        if (value.length < 2) {
                          return 'Le nom doit contenir au moins 2 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Téléphone
                    CustomInput(
                      controller: _telephoneController,
                      label: 'Téléphone',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre téléphone';
                        }
                        // Validation simple pour les numéros maliens (8 chiffres)
                        if (!RegExp(r'^[0-9]{8}$').hasMatch(value)) {
                          return 'Numéro invalide (8 chiffres requis)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mot de passe
                    CustomInput(
                      controller: _passwordController,
                      label: 'Mot de passe',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: TementColors.greySecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un mot de passe';
                        }
                        if (value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirmation mot de passe
                    CustomInput(
                      controller: _confirmPasswordController,
                      label: 'Confirmer le mot de passe',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: TementColors.greySecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez confirmer votre mot de passe';
                        }
                        if (value != _passwordController.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Sélection du rôle
                    Text(
                      'Vous êtes :',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildRoleCard(
                            title: 'Locataire',
                            icon: Icons.person_outline,
                            value: 'locataire',
                            description: 'Je cherche à louer',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildRoleCard(
                            title: 'Propriétaire',
                            icon: Icons.home_outlined,
                            value: 'proprietaire',
                            description: 'Je veux louer mon bien',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Bouton d'inscription
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return CustomButton(
                          text: 'S\'inscrire',
                          onPressed: _handleRegister,
                          isLoading: authProvider.isLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Lien vers connexion
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Déjà un compte ? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Se connecter',
                            style: TextStyle(
                              color: TementColors.sunsetOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required IconData icon,
    required String value,
    required String description,
  }) {
    final isSelected = _selectedRole == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? TementColors.indigoTech : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? TementColors.indigoTech
                : TementColors.greySecondary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: TementColors.indigoTech.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? Colors.white : TementColors.greySecondary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : TementColors.darkBackground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : TementColors.greySecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

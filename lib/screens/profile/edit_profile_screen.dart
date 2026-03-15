import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/auth_provider.dart';
import 'package:tement_mobile/widgets/custom_input.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:tement_mobile/services/upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  bool _showPasswordFields = false;
  String? _originalNom;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nomController.text = user.nom;
      _telephoneController.text = user.telephone;
      _originalNom = user.nom;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Erreur lors de la sélection de l\'image');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        bool success;

        // 1. Uploader la photo si sélectionnée
        String? photoUrl;
        if (_selectedImage != null) {
          print('📤 Upload de la nouvelle photo...');
          photoUrl = await UploadService().uploadProfilePhoto(_selectedImage!);
          print('✅ Photo uploadée: $photoUrl');
        }

        // 2. Déterminer si le nom a changé
        final nomChanged = _nomController.text != _originalNom;

        // 3. Mettre à jour le profil (seulement si nécessaire)
        if (nomChanged ||
            photoUrl != null ||
            _passwordController.text.isNotEmpty) {
          success = await authProvider.updateProfile(
            nom: nomChanged ? _nomController.text : null,
            motDePasse: _passwordController.text.isNotEmpty
                ? _passwordController.text
                : null,
            photoUrl: photoUrl,
          );
        } else {
          // Rien n'a changé
          success = true;
        }

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Profil mis à jour avec succès'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context, true);
        } else if (mounted) {
          _showError(authProvider.error ?? 'Erreur lors de la mise à jour');
        }
      } catch (e) {
        print('❌ Erreur: $e');
        _showError('Erreur: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Succès'),
        content: const Text('Votre profil a été mis à jour avec succès.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le profil'),
        backgroundColor: TementColors.indigoTech,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _selectedImage != null
                        ? 'Upload de la photo...'
                        : 'Mise à jour du profil...',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Photo de profil
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: TementColors.indigoTech,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (user?.photoUrl != null
                                  ? NetworkImage(user!.photoUrl!)
                                  : null) as ImageProvider?,
                          child:
                              _selectedImage == null && user?.photoUrl == null
                                  ? Text(
                                      user?.nom[0].toUpperCase() ?? 'U',
                                      style: const TextStyle(
                                        fontSize: 40,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: TementColors.sunsetOrange,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Indication pour la photo
                    if (_selectedImage != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Nouvelle photo sélectionnée',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Nom (modifiable)
                    CustomInput(
                      controller: _nomController,
                      label: 'Nom complet',
                      prefixIcon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est requis';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Téléphone (non modifiable)
                    CustomInput(
                      controller: _telephoneController,
                      label: 'Téléphone',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      enabled: false,
                    ),

                    const SizedBox(height: 8),

                    // Message d'info téléphone
                    Container(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        'Le numéro de téléphone ne peut pas être modifié',
                        style: TextStyle(
                          color: TementColors.greySecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Option de changement de mot de passe
                    Card(
                      elevation: 0,
                      color: TementColors.lightBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              _showPasswordFields
                                  ? Icons.lock_open
                                  : Icons.lock_outline,
                              color: TementColors.indigoTech,
                            ),
                            title: Text(
                              _showPasswordFields
                                  ? 'Annuler le changement de mot de passe'
                                  : 'Changer le mot de passe',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: Icon(
                              _showPasswordFields
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                            ),
                            onTap: () {
                              setState(() {
                                _showPasswordFields = !_showPasswordFields;
                                if (!_showPasswordFields) {
                                  _passwordController.clear();
                                  _confirmPasswordController.clear();
                                }
                              });
                            },
                          ),
                          if (_showPasswordFields) ...[
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  CustomInput(
                                    controller: _passwordController,
                                    label: 'Nouveau mot de passe',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: true,
                                    validator: (value) {
                                      if (_showPasswordFields &&
                                          (value == null || value.isEmpty)) {
                                        return 'Le mot de passe est requis';
                                      }
                                      if (value != null &&
                                          value.isNotEmpty &&
                                          value.length < 6) {
                                        return 'Minimum 6 caractères';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  CustomInput(
                                    controller: _confirmPasswordController,
                                    label: 'Confirmer le mot de passe',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: true,
                                    validator: (value) {
                                      if (_showPasswordFields &&
                                          value != _passwordController.text) {
                                        return 'Les mots de passe ne correspondent pas';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Bouton de sauvegarde
                    CustomButton(
                      text: 'Enregistrer les modifications',
                      onPressed: _handleSubmit,
                      isLoading: _isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Bouton annuler
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: TementColors.greySecondary,
                      ),
                      child: const Text('Annuler'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

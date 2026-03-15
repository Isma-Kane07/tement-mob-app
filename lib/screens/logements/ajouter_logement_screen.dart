import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/widgets/custom_input.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:tement_mobile/providers/logement_provider.dart';
import 'package:tement_mobile/services/upload_service.dart';

class AjouterLogementScreen extends StatefulWidget {
  const AjouterLogementScreen({super.key});

  @override
  State<AjouterLogementScreen> createState() => _AjouterLogementScreenState();
}

class _AjouterLogementScreenState extends State<AjouterLogementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adresseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();

  String _selectedType = 'maison';
  final List<String> _types = ['maison', 'appartement', 'studio'];

  final List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  final UploadService _uploadService = UploadService();

  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _adresseController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  Future<void> _prendrePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedImages.add(File(photo.path));
        });
      }
    } catch (e) {
      _showError('Erreur lors de la prise de photo');
    }
  }

  Future<void> _choisirDepuisGalerie() async {
    try {
      final List<XFile> photos = await _picker.pickMultiImage(
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (photos.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(photos.map((photo) => File(photo.path)));
        });
      }
    } catch (e) {
      _showError('Erreur lors de la sélection des photos');
    }
  }

  void _supprimerPhoto(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        _showError('Veuillez ajouter au moins une photo');
        return;
      }

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      try {
        // ✅ ÉTAPE 1: Uploader les photos vers le serveur
        print('📤 Upload de ${_selectedImages.length} photos...');

        // Simuler une progression (optionnel)
        Future.delayed(Duration(milliseconds: 500), () {
          setState(() => _uploadProgress = 0.3);
        });

        final photoUrls =
            await _uploadService.uploadMultiplePhotos(_selectedImages);

        setState(() => _uploadProgress = 1.0);
        print('✅ Photos uploadées: $photoUrls');

        // ✅ ÉTAPE 2: Créer le logement avec les URLs des photos
        final logementProvider =
            Provider.of<LogementProvider>(context, listen: false);

        final success = await logementProvider.addLogement(
          type: _selectedType,
          adresse: _adresseController.text,
          description: _descriptionController.text,
          prixNuit: double.parse(_prixController.text),
          photos: photoUrls,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Logement ajouté avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (mounted) {
          _showError(logementProvider.error ?? 'Erreur lors de l\'ajout');
        }
      } catch (e) {
        print('❌ Erreur: $e');
        _showError('Erreur: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un logement'),
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _uploadProgress > 0 ? _uploadProgress : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _uploadProgress < 0.3
                        ? 'Préparation des photos...'
                        : _uploadProgress < 1.0
                            ? 'Upload des photos...'
                            : 'Création du logement...',
                  ),
                  if (_uploadProgress > 0 && _uploadProgress < 1.0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: LinearProgressIndicator(
                        value: _uploadProgress,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          TementColors.sunsetOrange,
                        ),
                      ),
                    ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type de logement
                    Text(
                      'Type de logement',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: _types.map((type) {
                        return ButtonSegment(
                          value: type,
                          label: Text(_getTypeLabel(type)),
                          icon: Icon(_getTypeIcon(type)),
                        );
                      }).toList(),
                      selected: {_selectedType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _selectedType = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return TementColors.indigoTech;
                            }
                            return Colors.grey.shade100;
                          },
                        ),
                        foregroundColor:
                            MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Colors.white;
                            }
                            return TementColors.greySecondary;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 📸 SECTION PHOTOS
                    Text(
                      'Photos du logement',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    // Grille des photos sélectionnées
                    if (_selectedImages.isNotEmpty) ...[
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(_selectedImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _supprimerPhoto(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Boutons d'ajout de photos
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _prendrePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Prendre photo'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _choisirDepuisGalerie,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galerie'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Adresse
                    CustomInput(
                      controller: _adresseController,
                      label: 'Adresse',
                      prefixIcon: Icons.location_on_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'L\'adresse est requise';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Prix
                    CustomInput(
                      controller: _prixController,
                      label: 'Prix par nuit (FCFA)',
                      prefixIcon: Icons.money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le prix est requis';
                        }
                        final prix = double.tryParse(value);
                        if (prix == null) {
                          return 'Veuillez entrer un nombre valide';
                        }
                        if (prix < 5000) {
                          return 'Le prix minimum est de 5000 FCFA';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    CustomInput(
                      controller: _descriptionController,
                      label: 'Description',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La description est requise';
                        }
                        if (value.length < 20) {
                          return 'La description doit faire au moins 20 caractères';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Bouton de soumission
                    CustomButton(
                      text: 'Publier le logement',
                      onPressed: _handleSubmit,
                    ),
                    const SizedBox(height: 16),

                    // Information sur les photos
                    Center(
                      child: Text(
                        '${_selectedImages.length} photo(s) sélectionnée(s)',
                        style: TextStyle(
                          color: TementColors.greySecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'maison':
        return 'Maison';
      case 'appartement':
        return 'Appartement';
      case 'studio':
        return 'Studio';
      default:
        return type;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'maison':
        return Icons.house_outlined;
      case 'appartement':
        return Icons.apartment_outlined;
      case 'studio':
        return Icons.meeting_room_outlined;
      default:
        return Icons.home_outlined;
    }
  }
}

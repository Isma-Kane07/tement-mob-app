import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/models/logement.dart';
import 'package:tement_mobile/providers/logement_provider.dart';
import 'package:tement_mobile/widgets/custom_input.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:tement_mobile/services/upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ModifierLogementScreen extends StatefulWidget {
  final Logement logement;

  const ModifierLogementScreen({super.key, required this.logement});

  @override
  State<ModifierLogementScreen> createState() => _ModifierLogementScreenState();
}

class _ModifierLogementScreenState extends State<ModifierLogementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _adresseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();

  String _selectedType = 'maison';
  final List<String> _types = ['maison', 'appartement', 'studio'];

  List<File> _newImages = [];
  List<String> _existingPhotos = [];
  final ImagePicker _picker = ImagePicker();
  final UploadService _uploadService = UploadService();

  bool _isSubmitting = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    final logement = widget.logement;

    // Remplir les champs avec les données existantes
    _adresseController.text = logement.adresse;
    _descriptionController.text = logement.description ?? '';
    _prixController.text = logement.prixNuit.toString();
    _selectedType = logement.type;
    _existingPhotos = List.from(logement.photos);
  }

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
          _newImages.add(File(photo.path));
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
          _newImages.addAll(photos.map((photo) => File(photo.path)));
        });
      }
    } catch (e) {
      _showError('Erreur lors de la sélection des photos');
    }
  }

  void _supprimerPhotoExistante(int index) {
    setState(() {
      _existingPhotos.removeAt(index);
    });
  }

  void _supprimerNouvellePhoto(int index) {
    setState(() {
      _newImages.removeAt(index);
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
      setState(() {
        _isSubmitting = true;
        _uploadProgress = 0.0;
      });

      try {
        List<String> allPhotos = [..._existingPhotos];

        // ✅ Uploader les nouvelles photos si nécessaire
        if (_newImages.isNotEmpty) {
          print('📤 Upload de ${_newImages.length} nouvelles photos...');

          setState(() => _uploadProgress = 0.3);

          final newPhotoUrls =
              await _uploadService.uploadMultiplePhotos(_newImages);

          setState(() => _uploadProgress = 0.8);
          allPhotos.addAll(newPhotoUrls);
          print('✅ Nouvelles photos uploadées: $newPhotoUrls');
        }

        setState(() => _uploadProgress = 1.0);

        // ✅ Mettre à jour le logement
        final logementProvider =
            Provider.of<LogementProvider>(context, listen: false);

        final success = await logementProvider.updateLogement(
          id: widget.logement.id,
          type: _selectedType,
          adresse: _adresseController.text,
          description: _descriptionController.text,
          prixNuit: double.parse(_prixController.text),
          photos: allPhotos,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Logement modifié avec succès !'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else if (mounted) {
          _showError(
              logementProvider.error ?? 'Erreur lors de la modification');
        }
      } catch (e) {
        print('❌ Erreur: $e');
        _showError('Erreur: ${e.toString()}');
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }

  Future<void> _supprimerLogement() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le logement'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer ce logement ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isSubmitting = true);

      try {
        final logementProvider =
            Provider.of<LogementProvider>(context, listen: false);
        final success =
            await logementProvider.deleteLogement(widget.logement.id);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logement supprimé'),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        _showError('Erreur: $e');
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier le logement'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _supprimerLogement,
          ),
        ],
      ),
      body: _isSubmitting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_uploadProgress > 0 && _uploadProgress < 1.0) ...[
                    CircularProgressIndicator(value: _uploadProgress),
                    const SizedBox(height: 16),
                    Text(
                        'Upload des photos... ${(_uploadProgress * 100).toInt()}%'),
                  ] else ...[
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    const Text('Modification en cours...'),
                  ],
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
                    ),
                    const SizedBox(height: 24),

                    // Photos existantes
                    if (_existingPhotos.isNotEmpty) ...[
                      Text(
                        'Photos actuelles',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _existingPhotos.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(_existingPhotos[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _supprimerPhotoExistante(index),
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
                      const SizedBox(height: 16),
                    ],

                    // Nouvelles photos
                    if (_newImages.isNotEmpty) ...[
                      Text(
                        'Nouvelles photos',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _newImages.length,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(_newImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _supprimerNouvellePhoto(index),
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
                      const SizedBox(height: 16),
                    ],

                    // Boutons d'ajout de photos
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _prendrePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Prendre photo'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _choisirDepuisGalerie,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galerie'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Adresse
                    CustomInput(
                      controller: _adresseController,
                      label: 'Adresse complète',
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
                      prefixIcon: Icons.attach_money,
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

                    // Boutons
                    CustomButton(
                      text: 'Enregistrer les modifications',
                      onPressed: _handleSubmit,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Annuler'),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/models/logement.dart';
import 'package:tement_mobile/providers/auth_provider.dart';
import 'package:tement_mobile/widgets/custom_button.dart';
import 'package:tement_mobile/screens/reservations/creer_reservation_screen.dart';

class DetailLogementScreen extends StatefulWidget {
  final Logement logement;

  const DetailLogementScreen({super.key, required this.logement});

  @override
  State<DetailLogementScreen> createState() => _DetailLogementScreenState();
}

class _DetailLogementScreenState extends State<DetailLogementScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final logement = widget.logement;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: TementColors.indigoTech,
            flexibleSpace: FlexibleSpaceBar(
              background: logement.photos.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          controller: _pageController,
                          itemCount: logement.photos.length,
                          onPageChanged: (index) {
                            setState(() => _currentImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              logement.photos[index],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color:
                                    TementColors.greySecondary.withOpacity(0.3),
                                child: const Center(
                                  child: Icon(Icons.broken_image, size: 50),
                                ),
                              ),
                            );
                          },
                        ),
                        if (logement.photos.length > 1)
                          Positioned(
                            bottom: 16,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                logement.photos.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentImageIndex == index
                                        ? TementColors.sunsetOrange
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Container(
                      color: TementColors.greySecondary.withOpacity(0.3),
                      child: const Center(
                        child: Icon(Icons.no_photography, size: 50),
                      ),
                    ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: TementColors.softGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        logement.typeEnFrancais,
                        style: const TextStyle(
                          color: TementColors.softGold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          logement.formattedPrix,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: TementColors.indigoTech,
                          ),
                        ),
                        const Text(
                          ' /nuit',
                          style: TextStyle(
                            color: TementColors.greySecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: TementColors.greySecondary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        logement.adresse,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline,
                        color: TementColors.greySecondary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Propriétaire: ${logement.proprietaire?.nom ?? 'Inconnu'}',
                      style: const TextStyle(color: TementColors.greySecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  logement.description ?? 'Aucune description disponible',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.user?.id == logement.proprietaireId) {
              return const SizedBox.shrink();
            }

            return CustomButton(
              text: 'Réserver maintenant',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreerReservationScreen(
                      logement: logement,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

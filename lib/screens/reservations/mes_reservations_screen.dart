// lib/screens/reservations/mes_reservations_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/models/reservation.dart';
import 'package:tement_mobile/providers/reservation_provider.dart';
import 'package:tement_mobile/providers/auth_provider.dart';
import 'package:tement_mobile/screens/reservations/detail_reservation_screen.dart';
import 'package:tement_mobile/widgets/reservation_card.dart';

class MesReservationsScreen extends StatefulWidget {
  const MesReservationsScreen({super.key});

  @override
  State<MesReservationsScreen> createState() => _MesReservationsScreenState();
}

class _MesReservationsScreenState extends State<MesReservationsScreen>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservations();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reservationProvider =
        Provider.of<ReservationProvider>(context, listen: false);
    await reservationProvider.loadReservations(authProvider);
  }

  List<Reservation> _filterReservations(List<Reservation> reservations) {
    final now = DateTime.now();

    switch (_selectedTab) {
      case 0: // À venir
        return reservations.where((r) {
          return r.dateDebut.isAfter(now) &&
              (r.statut == 'confirme' ||
                  r.statut == 'en_attente' ||
                  r.statut == 'paye');
        }).toList();
      case 1: // Passées
        return reservations.where((r) {
          return r.dateFin.isBefore(now) &&
              (r.statut == 'confirme' || r.statut == 'paye');
        }).toList();
      case 2: // Annulées
        return reservations.where((r) => r.statut == 'annule').toList();
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isProprietaire = user?.isProprietaire ?? false;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          isProprietaire ? 'Réservations reçues' : 'Mes réservations',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: TementColors.indigoTech,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: TementColors.indigoTech,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: TementColors.indigoTech.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  // ✅ SUPPRIME LA LIGNE HORIZONTALE
                  indicator: const BoxDecoration(),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: TementColors.indigoTech,
                  unselectedLabelColor: TementColors.greySecondary,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  // ✅ AJOUTE UN DIVIDER INVISIBLE POUR ÉVITER LE CHANGEMENT DE COULEUR
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'À venir'),
                    Tab(text: 'Passées'),
                    Tab(text: 'Annulées'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.reservations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: TementColors.indigoTech.withOpacity(0.1),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          TementColors.sunsetOrange,
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Chargement',
                    style: TextStyle(
                      fontSize: 16,
                      color: TementColors.greySecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade300,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Une erreur est survenue',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: TementColors.indigoTech,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: TementColors.greySecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: _loadReservations,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: TementColors.indigoTech,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Réessayer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final filtered = _filterReservations(provider.reservations);

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: TementColors.indigoTech.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getEmptyIcon(),
                      size: 64,
                      color: TementColors.greySecondary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _getEmptyTitle(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: TementColors.indigoTech,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getEmptyMessage(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: TementColors.greySecondary,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadReservations,
            color: TementColors.sunsetOrange,
            backgroundColor: Colors.white,
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final reservation = filtered[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ReservationCard(
                    reservation: reservation,
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation,
                                  secondaryAnimation) =>
                              DetailReservationScreen(reservation: reservation),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  IconData _getEmptyIcon() {
    switch (_selectedTab) {
      case 0:
        return Icons.calendar_today_outlined;
      case 1:
        return Icons.history;
      default:
        return Icons.cancel_outlined;
    }
  }

  String _getEmptyTitle() {
    switch (_selectedTab) {
      case 0:
        return 'Aucune réservation à venir';
      case 1:
        return 'Aucune réservation passée';
      default:
        return 'Aucune réservation annulée';
    }
  }

  String _getEmptyMessage() {
    switch (_selectedTab) {
      case 0:
        return 'Explorez les logements\net découvrez votre prochain séjour';
      case 1:
        return 'Vos anciens séjours\napparaîtront ici';
      default:
        return 'Vous n\'avez aucune\nréservation annulée';
    }
  }
}

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

class _MesReservationsScreenState extends State<MesReservationsScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservations();
    });
  }

  Future<void> _loadReservations() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reservationProvider =
        Provider.of<ReservationProvider>(context, listen: false);

    // ✅ Utiliser la nouvelle méthode qui charge selon le rôle
    await reservationProvider.loadReservations(authProvider);
  }

  List<Reservation> _filterReservations(List<Reservation> reservations) {
    final now = DateTime.now();

    switch (_selectedTab) {
      case 0: // À venir
        return reservations.where((r) {
          return r.dateDebut.isAfter(now) &&
              (r.statut == 'confirme' || r.statut == 'en_attente');
        }).toList();
      case 1: // Passées
        return reservations.where((r) {
          return r.dateFin.isBefore(now) || r.statut == 'termine';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(user?.isProprietaire ?? false
            ? 'Réservations reçues'
            : 'Mes réservations'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: TementColors.indigoTech,
      ),
      body: Consumer<ReservationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.reservations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReservations,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final filtered = _filterReservations(provider.reservations);

          return Column(
            children: [
              // Onglets
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildTab('À venir', 0),
                    _buildTab('Passées', 1),
                    _buildTab('Annulées', 2),
                  ],
                ),
              ),

              // Liste
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 80,
                              color:
                                  TementColors.greySecondary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getEmptyMessage(user?.isProprietaire ?? false),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadReservations,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final reservation = filtered[index];
                            return ReservationCard(
                              reservation: reservation,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailReservationScreen(
                                      reservation: reservation,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isSelected ? TementColors.sunsetOrange : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? TementColors.sunsetOrange
                  : TementColors.greySecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  String _getEmptyMessage(bool isProprietaire) {
    switch (_selectedTab) {
      case 0:
        return isProprietaire
            ? 'Aucune réservation à venir pour vos logements'
            : 'Aucune réservation à venir';
      case 1:
        return 'Aucune réservation passée';
      default:
        return 'Aucune réservation annulée';
    }
  }
}

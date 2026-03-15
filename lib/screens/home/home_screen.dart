import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/auth_provider.dart';
import 'package:tement_mobile/screens/logements/logements_screen.dart';
import 'package:tement_mobile/screens/reservations/mes_reservations_screen.dart';
import 'package:tement_mobile/screens/profile/profile_screen.dart';
import 'package:tement_mobile/screens/wallet/wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;
  late final List<BottomNavigationBarItem> _navItems;

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;

    // Écrans pour tous les utilisateurs
    _screens = [
      const LogementsScreen(), // 0: Liste des logements
      const MesReservationsScreen(), // 1: Mes réservations
      const ProfileScreen(), // 2: Profil
    ];

    // Items de navigation de base
    _navItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Accueil',
      ),
      BottomNavigationBarItem(
        icon: Icon(user?.isProprietaire ?? false
            ? Icons.receipt_outlined
            : Icons.calendar_today_outlined),
        activeIcon: Icon(user?.isProprietaire ?? false
            ? Icons.receipt
            : Icons.calendar_today),
        label:
            user?.isProprietaire ?? false ? 'Réservations' : 'Mes réservations',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
      ),
    ];

    // Ajouter l'écran wallet pour les propriétaires
    if (user?.isProprietaire ?? false) {
      _screens.insert(1, const WalletScreen()); // Wallet en position 1
      _navItems.insert(
          1,
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: TementColors.sunsetOrange,
          unselectedItemColor: TementColors.greySecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: _navItems,
        ),
      ),
    );
  }
}

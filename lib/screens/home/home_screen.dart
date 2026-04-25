// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/auth_provider.dart';
import 'package:tement_mobile/screens/logements/logements_screen.dart';
import 'package:tement_mobile/screens/reservations/mes_reservations_screen.dart';
import 'package:tement_mobile/screens/profile/profile_screen.dart';
import 'package:tement_mobile/screens/wallet/wallet_screen.dart';
import 'package:tement_mobile/screens/admin/admin_dashboard_screen.dart';
import 'package:tement_mobile/screens/admin/admin_paiements_screen.dart';
import 'package:tement_mobile/screens/admin/admin_retraits_screen.dart';
import 'package:tement_mobile/screens/admin/admin_utilisateurs_screen.dart';
import 'package:tement_mobile/screens/admin/admin_commissions_screen.dart';
import 'package:tement_mobile/screens/admin/admin_transactions_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final isProprietaire = user?.isProprietaire ?? false;
    final isAdmin = user?.isAdmin ?? false;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    TementColors.indigoTech.withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: IndexedStack(
              index: _selectedIndex,
              children: _buildScreens(isProprietaire, isAdmin),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(isProprietaire, isAdmin),
    );
  }

  List<Widget> _buildScreens(bool isProprietaire, bool isAdmin) {
    final screens = <Widget>[
      const LogementsScreen(),
    ];

    if (isAdmin) {
      // Menu Admin complet
      screens.addAll([
        const AdminDashboardScreen(), // Dashboard
        const AdminPaiementsScreen(), // Paiements en attente
        const AdminRetraitsScreen(), // Retraits en attente
        const AdminUtilisateursScreen(), // Utilisateurs
        const AdminCommissionsScreen(), // Commissions
        const AdminTransactionsScreen(), // Transactions
        const ProfileScreen(), // Profil
      ]);
    } else if (isProprietaire) {
      screens.addAll([
        const WalletScreen(), // Portefeuille
        const MesReservationsScreen(), // Réservations
        const ProfileScreen(), // Profil
      ]);
    } else {
      // Locataire
      screens.addAll([
        const MesReservationsScreen(), // Mes réservations
        const ProfileScreen(), // Profil
      ]);
    }

    return screens;
  }

  Widget _buildBottomNavigationBar(bool isProprietaire, bool isAdmin) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: TementColors.indigoTech.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: TementColors.sunsetOrange,
          unselectedItemColor: TementColors.greySecondary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: _buildNavItems(isProprietaire, isAdmin),
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildNavItems(
      bool isProprietaire, bool isAdmin) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Accueil',
        tooltip: 'Accueil',
      ),
    ];

    if (isAdmin) {
      // Menu Admin
      items.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'Dashboard',
          tooltip: 'Tableau de bord',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.payment_outlined),
          activeIcon: Icon(Icons.payment),
          label: 'Paiements',
          tooltip: 'Paiements en attente',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.money_off_outlined),
          activeIcon: Icon(Icons.money_off),
          label: 'Retraits',
          tooltip: 'Retraits en attente',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          activeIcon: Icon(Icons.people),
          label: 'Utilisateurs',
          tooltip: 'Gestion utilisateurs',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.trending_up_outlined),
          activeIcon: Icon(Icons.trending_up),
          label: 'Commissions',
          tooltip: 'Mes commissions',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_outlined),
          activeIcon: Icon(Icons.receipt),
          label: 'Transactions',
          tooltip: 'Toutes les transactions',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Compte',
          tooltip: 'Mon profil',
        ),
      ]);
    } else if (isProprietaire) {
      // Menu Propriétaire
      items.addAll([
        const BottomNavigationBarItem(
          icon: Icon(Icons.account_balance_wallet_outlined),
          activeIcon: Icon(Icons.account_balance_wallet),
          label: 'Portefeuille',
          tooltip: 'Mon solde',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _selectedIndex == 2
                  ? TementColors.sunsetOrange.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt_outlined),
          ),
          activeIcon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: TementColors.sunsetOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.receipt),
          ),
          label: 'Réservations',
          tooltip: 'Réservations reçues',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Compte',
          tooltip: 'Mon profil',
        ),
      ]);
    } else {
      // Menu Locataire
      items.addAll([
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _selectedIndex == 1
                  ? TementColors.sunsetOrange.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_month_outlined),
          ),
          activeIcon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: TementColors.sunsetOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.calendar_month),
          ),
          label: 'Mes réservations',
          tooltip: 'Mes réservations',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Compte',
          tooltip: 'Mon profil',
        ),
      ]);
    }

    return items;
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/auth_provider.dart';
import 'package:tement_mobile/providers/logement_provider.dart';
import 'package:tement_mobile/providers/reservation_provider.dart';
import 'package:tement_mobile/screens/welcome/welcome_screen.dart';
import 'package:tement_mobile/screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LogementProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
      ],
      child: MaterialApp(
        title: 'Tement',
        debugShowCheckedModeBanner: false,
        theme: TementTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // ✅ Si l'utilisateur est connecté → Accueil
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    }

    // ✅ Sinon → Page de bienvenue
    return const WelcomeScreen();
  }
}

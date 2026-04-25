import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:tement_mobile/config/theme.dart';
import 'package:tement_mobile/providers/auth_provider.dart';
import 'package:tement_mobile/providers/logement_provider.dart';
import 'package:tement_mobile/providers/reservation_provider.dart';
import 'package:tement_mobile/providers/admin_provider.dart';
import 'package:tement_mobile/screens/welcome/welcome_screen.dart';
import 'package:tement_mobile/screens/home/home_screen.dart';
import 'package:tement_mobile/services/notification_service.dart';
import 'firebase_options.dart';

void main() async {
  // ✅ IMPORTANT: Initialiser les bindings avant toute opération asynchrone
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Initialiser Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('🔥 Firebase initialisé avec succès');

  // ✅ Initialiser les données de localisation pour le français
  await initializeDateFormatting('fr_FR', null);

  // ✅ Définir la locale par défaut
  Intl.defaultLocale = 'fr_FR';

  // 🔔 Initialiser le service de notifications
  final notificationService = NotificationService();
  await notificationService.initialize();

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
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Tement',
        debugShowCheckedModeBanner: false,
        theme: TementTheme.lightTheme,

        // ✅ AJOUTER les delegates de localisation
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('fr', 'FR'), // Français
          Locale('en', 'US'), // Anglais (fallback)
        ],
        locale: const Locale('fr', 'FR'), // Forcer le français

        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Utiliser Consumer pour s'assurer que le widget se rebuild
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        print(
            '🔄 AuthWrapper rebuild - isLoading: ${authProvider.isLoading}, isAuthenticated: ${authProvider.isAuthenticated}');

        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // ✅ Si l'utilisateur est connecté → Accueil
        if (authProvider.isAuthenticated) {
          print('✅ AuthWrapper: Navigation vers HomeScreen');
          return const HomeScreen();
        }

        // ✅ Sinon → Page de bienvenue
        print('❌ AuthWrapper: Navigation vers WelcomeScreen');
        return const WelcomeScreen();
      },
    );
  }
}

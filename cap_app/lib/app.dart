import 'package:flutter/material.dart';
import 'features/auth/screens/sign_in_screen.dart';
// J'ajoute un préfixe 'auth' pour résoudre l'ambiguïté
import 'features/auth/screens/sign_up_screen.dart' as auth;
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_navbar.dart';
import 'screens/historique_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cap projet App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SignInScreen(),
        '/signup': (_) => const auth.SignUpScreen(),
        '/main': (_) => const MainPage(),
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  String? _mutuelleName;
  String? _planName;
  String? _estEtudiant;

  void _onPlanSelectionComplete(String mutuelle, String plan) {
    setState(() {
      _mutuelleName = mutuelle;
      _planName = plan;
      _selectedIndex = 2; // Assurez-vous que l'onglet de profil est actif
    });
  }

  void _clearPlanSelection() {
    setState(() {
      _mutuelleName = null;
      _planName = null;
    });
  }

  void _setEtudiantStatus(String status) {
    setState(() {
      _estEtudiant = status;
    });
  }

  void _clearEtudiantStatus() {
    setState(() {
      _estEtudiant = null;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreen(),
      const HistoriqueScreen(),
      ProfileScreen(
        mutuelleName: _mutuelleName,
        planName: _planName,
        onPlanSelectionComplete: _onPlanSelectionComplete,
        onClearPlanSelection: _clearPlanSelection,
        estEtudiant: _estEtudiant,
        onSetEtudiantStatus: _setEtudiantStatus,
        onClearEtudiantStatus: _clearEtudiantStatus,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

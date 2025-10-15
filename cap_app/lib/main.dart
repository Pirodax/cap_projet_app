import 'package:cap_app/screens/SignUp_screen.dart';
import 'package:flutter/material.dart';
import 'widgets/bottom_navbar.dart' ;
import 'screens/home_screen.dart' ;
import 'screens/profile_screen.dart' ;
import 'screens/historique_screen.dart';
import 'screens/SignIn_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'cap Projet App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        // Modern theme setup
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
      // 1. Point d'entrée de l'application
      initialRoute: '/',
      // 2. Définition des routes
      routes: {
        '/': (_) => const SignInScreen(),
        '/signup': (_) => const SignUpScreen(),
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

  final List<Widget> _pages = const [
    HomeScreen(),
    HistoriqueScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

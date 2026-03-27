import 'package:flutter/material.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/sign_up_screen.dart' as auth;
import 'features/home/screens/home_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'widgets/bottom_navbar.dart';
import 'features/history/screens/historique_page.dart';
import 'core/supabase/supabase_init.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cap Projet App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
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

  @override
  void initState() {
    super.initState();
    _checkProfileCompleteness();
  }

  Future<void> _checkProfileCompleteness() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final data = await supabase
          .from('user_infos')
          .select('mutuelle_formule_id, regime_assurance_maladie_id')
          .eq('user_id', user.id)
          .maybeSingle();

      final isIncomplete = data == null ||
          data['mutuelle_formule_id'] == null ||
          data['regime_assurance_maladie_id'] == null;

      if (isIncomplete && mounted) {
        setState(() => _selectedIndex = 2);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Complétez votre profil pour accéder aux simulations'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.teal.shade600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Erreur vérification profil: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomeScreen(),
      HistoriquePage(isActive: _selectedIndex == 1),
      ProfileScreen(onProfileCompleted: () {
        setState(() => _selectedIndex = 0);
      }),
    ];

    return Scaffold(
      extendBody: true,
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

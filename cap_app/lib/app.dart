import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/screens/sign_in_screen.dart';
import 'features/auth/screens/sign_up_screen.dart' as auth;
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/bottom_navbar.dart';
import 'features/History/historique_page.dart';
import 'services/category_service.dart';
import 'services/profile_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cap Projet App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
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
      home: const AuthStateListener(),
      routes: {
        '/signup': (_) => const auth.SignUpScreen(),
      },
    );
  }
}

class AuthStateListener extends StatelessWidget {
  final SupabaseClient? supabaseClient;
  final CategoryService? categoryService;
  final ProfileService? profileService;

  const AuthStateListener({
    super.key, 
    this.supabaseClient,
    this.categoryService,
    this.profileService,
  });

  @override
  Widget build(BuildContext context) {
    final client = supabaseClient ?? Supabase.instance.client;
    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data?.session != null) {
          return MainPage(
            categoryService: categoryService,
            profileService: profileService,
          );
        } 
        else {
          return SignInScreen(supabaseClient: supabaseClient);
        }
      },
    );
  }
}


class MainPage extends StatefulWidget {
  final CategoryService? categoryService;
  final ProfileService? profileService;

  const MainPage({super.key, this.categoryService, this.profileService});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(categoryService: widget.categoryService),
      const HistoriquePage(),
      ProfileScreen(profileService: widget.profileService),
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

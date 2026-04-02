import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _showOnboarding = false;

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
        setState(() => _showOnboarding = true);
      }
    } catch (e) {
      debugPrint('Erreur vérification profil: $e');
    }
  }

  void _dismissOnboarding() {
    setState(() {
      _showOnboarding = false;
      _selectedIndex = 2;
    });
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
        setState(() {
          _selectedIndex = 0;
          _showOnboarding = false;
        });
      }),
    ];

    return Stack(
      children: [
        Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: BottomNavBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ),
        if (_showOnboarding) _buildOnboardingOverlay(context),
      ],
    );
  }

  Widget _buildOnboardingOverlay(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Position du bouton Profil dans la navbar (3e bouton sur 3, spaceAround)
    // spaceAround: espace = largeur / (n*2), centres = espace + i * (largeur/n)
    final navBarHeight = 56.0 + bottomPadding;
    final profileButtonX = screenSize.width * (5 / 6) + 4;
    final profileButtonY = screenSize.height - (navBarHeight / 2);
    final spotlightCenter = Offset(profileButtonX, profileButtonY);
    const spotlightRadius = 45.0;

    return GestureDetector(
      onTap: _dismissOnboarding,
      child: Stack(
        children: [
          // Fond noir avec cercle decoupe
          CustomPaint(
            size: screenSize,
            painter: _SpotlightPainter(
              center: spotlightCenter,
              radius: spotlightRadius,
            ),
          ),

          // Texte centre au-dessus du spotlight
          Positioned(
            left: 30,
            right: 30,
            bottom: navBarHeight + spotlightRadius + 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Commencez ici !',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Renseignez votre mutuelle pour\ndécouvrir vos remboursements',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white70,
                      height: 1.5,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Offset center;
  final double radius;

  _SpotlightPainter({required this.center, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // Fond noir 75%
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withAlpha(190),
    );

    // Decoupe cercle transparent
    canvas.drawCircle(
      center,
      radius,
      Paint()..blendMode = BlendMode.clear,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.center != center || oldDelegate.radius != radius;
  }
}

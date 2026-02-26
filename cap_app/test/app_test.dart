import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/app.dart';
import 'package:loodo_app/features/auth/screens/sign_in_screen.dart';
import 'package:loodo_app/screens/home_screen.dart';
import 'package:loodo_app/features/History/historique_page.dart';
import 'package:loodo_app/screens/profile_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements MockGoTrueClientProxy {} 
class MockAuthResponse extends Mock implements AuthResponse {}
class MockSession extends Mock implements Session {}

abstract class MockGoTrueClientProxy extends GoTrueClient {
  MockGoTrueClientProxy() : super(url: '', headers: {});
}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late StreamController<AuthState> authStateController;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: 'https://test.com', anonKey: 'key');
  });

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    authStateController = StreamController<AuthState>.broadcast();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.onAuthStateChange).thenAnswer((_) => authStateController.stream);
  });

  tearDown(() {
    authStateController.close();
  });

  group('App Navigation & Auth Logic', () {
    testWidgets('AuthStateListener shows loading then SignInScreen when no session', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AuthStateListener(supabaseClient: mockSupabase),
      ));

      // 1. État initial (Waiting sur le StreamBuilder)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 2. Émission d'un état non connecté
      authStateController.add(AuthState(AuthChangeEvent.signedOut, null));
      await tester.pumpAndSettle();

      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('AuthStateListener shows MainPage when session exists', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AuthStateListener(supabaseClient: mockSupabase),
      ));

      // Émission d'un état connecté
      final mockSession = MockSession();
      authStateController.add(AuthState(AuthChangeEvent.signedIn, mockSession));
      await tester.pumpAndSettle();

      expect(find.byType(MainPage), findsOneWidget);
    });

    testWidgets('MainPage navigation between tabs works', (tester) async {
      // On mock le client pour les sous-écrans (HomeScreen, etc.)
      await tester.pumpWidget(const MaterialApp(home: MainPage()));
      await tester.pumpAndSettle();

      // 1. Par défaut sur HomeScreen
      expect(find.byType(HomeScreen), findsOneWidget);

      // 2. Clic sur Historique
      await tester.tap(find.text('Historique'));
      await tester.pumpAndSettle();
      expect(find.byType(HistoriquePage), findsOneWidget);

      // 3. Clic sur Profil
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('MyApp theme and title are correct', (tester) async {
      await tester.pumpWidget(const MyApp());
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      
      expect(app.title, 'Cap Projet App');
      expect(app.theme?.useMaterial3, isTrue);
      expect(app.theme?.primaryColor, Colors.indigo);
    });
  });
}

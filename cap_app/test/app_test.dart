import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/app.dart';
import 'package:loodo_app/features/auth/screens/sign_in_screen.dart';
import 'package:loodo_app/screens/home_screen.dart';
import 'package:loodo_app/features/History/historique_page.dart';
import 'package:loodo_app/screens/profile_screen.dart';
import 'package:loodo_app/services/category_service.dart';
import 'package:loodo_app/services/profile_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements MockGoTrueClientProxy {} 
class MockSession extends Mock implements Session {}
class MockCategoryService extends Mock implements CategoryService {}
class MockProfileService extends Mock implements ProfileService {}

abstract class MockGoTrueClientProxy extends GoTrueClient {
  MockGoTrueClientProxy() : super(url: '', headers: {});
}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;
  late MockCategoryService mockCategoryService;
  late MockProfileService mockProfileService;
  late StreamController<AuthState> authStateController;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: 'https://test.com', anonKey: 'key');
  });

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    mockCategoryService = MockCategoryService();
    mockProfileService = MockProfileService();
    authStateController = StreamController<AuthState>.broadcast();

    when(() => mockSupabase.auth).thenReturn(mockAuth);
    when(() => mockAuth.onAuthStateChange).thenAnswer((_) => authStateController.stream);
    
    // On stub les services pour éviter les erreurs Supabase 400 dans MainPage
    when(() => mockCategoryService.getCategories()).thenAnswer((_) async => []);
    when(() => mockProfileService.getMutuelles()).thenAnswer((_) async => []);
    when(() => mockProfileService.getFormules()).thenAnswer((_) async => []);
    when(() => mockProfileService.getRegimes()).thenAnswer((_) async => []);
    when(() => mockProfileService.getUserProfile()).thenAnswer((_) async => null);
  });

  tearDown(() {
    authStateController.close();
  });

  group('App Navigation & Auth Logic', () {
    testWidgets('AuthStateListener flows correctly', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: AuthStateListener(
          supabaseClient: mockSupabase,
          categoryService: mockCategoryService,
          profileService: mockProfileService,
        ),
      ));

      // 1. État initial (Loading)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 2. Émission SignedOut
      authStateController.add(AuthState(AuthChangeEvent.signedOut, null));
      // Utilisation de pump(Duration) au lieu de pumpAndSettle à cause de l'animation du skeleton
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.byType(SignInScreen), findsOneWidget);

      // 3. Émission SignedIn
      final mockSession = MockSession();
      authStateController.add(AuthState(AuthChangeEvent.signedIn, mockSession));
      await tester.pump(const Duration(milliseconds: 100));
      // On attend que HistoriquePage (dans MainPage) finisse son timer de 800ms
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump();

      expect(find.byType(MainPage), findsOneWidget);
    });

    testWidgets('MainPage navigation between tabs', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: MainPage(
          categoryService: mockCategoryService,
          profileService: mockProfileService,
        ),
      ));
      
      // Attendre que le timer de HistoriquePage se termine (800ms)
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigation vers Historique
      await tester.tap(find.text('Historique'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.byType(HistoriquePage), findsOneWidget);

      // Navigation vers Profil
      await tester.tap(find.text('Profil'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('MyApp properties', (tester) async {
      await tester.pumpWidget(const MyApp());
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.title, 'Cap Projet App');
    });
  });
}

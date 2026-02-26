import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/features/auth/screens/sign_up_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements MockGoTrueClientProxy {} 
class MockAuthResponse extends Mock implements AuthResponse {}

abstract class MockGoTrueClientProxy extends GoTrueClient {
  MockGoTrueClientProxy() : super(url: '', headers: {});
}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: 'https://test.com', anonKey: 'key');
  });

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
  });

  // Helper pour configurer une taille d'écran suffisante
  Future<void> setLargeDisplay(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget createTestWidget() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpScreen(supabaseClient: mockSupabase),
    );
  }

  group('SignUpScreen Tests', () {
    Finder signUpButton() => find.byType(FilledButton);

    testWidgets('Validation errors show up', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(createTestWidget());

      await tester.tap(signUpButton());
      await tester.pump();

      expect(find.text('Email requis'), findsOneWidget);
      expect(find.text('Mot de passe requis'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.tap(signUpButton());
      await tester.pump();
      expect(find.text('Email invalide'), findsOneWidget);
    });

    testWidgets('Successful signup shows snackbar and pops', (tester) async {
      await setLargeDisplay(tester);
      when(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {
            // Délai indispensable pour que le test "voit" le CircularProgressIndicator
            await Future.delayed(const Duration(milliseconds: 100));
            return MockAuthResponse();
          });

      // On utilise une structure avec navigation pour tester le pop()
      await tester.pumpWidget(MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Builder(builder: (context) {
            return ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SignUpScreen(supabaseClient: mockSupabase)),
              ),
              child: const Text('Go'),
            );
          }),
        ),
      ));

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'new@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(signUpButton());
      
      // 1. On pump pour déclencher l'état de chargement
      await tester.pump(); 
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // 2. On avance le temps pour laisser le mock finir
      await tester.pump(const Duration(milliseconds: 150));
      
      // 3. On attend la fin des animations (SnackBar + Pop)
      await tester.pumpAndSettle(); 

      expect(find.textContaining('Vérifie ton email'), findsOneWidget);
      expect(find.byType(SignUpScreen), findsNothing); 
    });

    testWidgets('Shows error from Supabase', (tester) async {
      await setLargeDisplay(tester);
      when(() => mockAuth.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            throw const AuthException('User already registered');
          });

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'exists@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(signUpButton());
      
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      expect(find.text('User already registered'), findsOneWidget);
    });

    testWidgets('Password visibility toggle', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(createTestWidget());

      Finder getPasswordField() => find.byType(TextField).at(1);
      
      expect(tester.widget<TextField>(getPasswordField()).obscureText, isTrue);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(tester.widget<TextField>(getPasswordField()).obscureText, isFalse);
    });
  });
}

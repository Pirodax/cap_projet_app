import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/features/auth/screens/sign_in_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements MockGoTrueClientProxy {} 
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}

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

  Widget createTestWidget() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/main': (context) => const Scaffold(body: Text('Main Page')),
        '/signup': (context) => const Scaffold(body: Text('Signup Page')),
      },
      home: SignInScreen(supabaseClient: mockSupabase),
    );
  }

  group('SignInScreen Tests', () {
    Finder loginButton() => find.byType(FilledButton);

    testWidgets('Validation errors show up', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.tap(loginButton());
      await tester.pump();
      expect(find.text('Email requis'), findsOneWidget);
      expect(find.text('Mot de passe requis'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.tap(loginButton());
      await tester.pump();
      expect(find.text('Email invalide'), findsOneWidget);
    });

    testWidgets('Shows error on invalid credentials', (tester) async {
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 50));
            throw const AuthException('invalid credentials');
          });

      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).at(0), 'wrong@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'wrongpassword');
      
      await tester.tap(loginButton());
      await tester.pump(); // Déclenche le loading
      await tester.pump(const Duration(milliseconds: 100)); // Attend l'exception
      await tester.pumpAndSettle(); // Attend le setState final

      // Utilisation d'un mot clé unique pour éviter les soucis de ponctuation
      expect(find.textContaining(RegExp(r'incorrect', caseSensitive: false)), findsOneWidget);
    });

    testWidgets('Shows error on unconfirmed email', (tester) async {
      when(() => mockAuth.signInWithPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 50));
            throw const AuthException('email not confirmed');
          });

      await tester.pumpWidget(createTestWidget());
      await tester.enterText(find.byType(TextFormField).at(0), 'unconfirmed@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      
      await tester.tap(loginButton());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.textContaining(RegExp(r'confirmé', caseSensitive: false)), findsOneWidget);
    });

    testWidgets('Password visibility toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      Finder getPasswordField() => find.byType(TextField).at(1);
      
      expect(tester.widget<TextField>(getPasswordField()).obscureText, isTrue);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(tester.widget<TextField>(getPasswordField()).obscureText, isFalse);
    });

    testWidgets('Navigate to signup', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle();
      expect(find.text('Signup Page'), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/features/auth/screens/sign_up_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthResponse extends Mock implements AuthResponse {}

void main() {
  late MockSupabaseClient mockSupabase;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockSupabase.auth).thenReturn(mockAuth);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: SignUpScreen(supabaseClient: mockSupabase),
    );
  }

  group('SignUpScreen Tests', () {
    testWidgets('Validation errors show up', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Créer un compte'));
      await tester.pump();

      expect(find.text('Email requis'), findsOneWidget);
      expect(find.text('Mot de passe requis'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.text('Créer un compte'));
      await tester.pump();
      expect(find.text('Email invalide'), findsOneWidget);
    });

    testWidgets('Successful signup shows snackbar and pops', (tester) async {
      when(() => mockAuth.signUp(
            email: 'new@example.com',
            password: 'password123',
          )).thenAnswer((_) async => MockAuthResponse());

      await tester.pumpWidget(MaterialApp(
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

      // Naviguer vers l'écran
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'new@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Créer un compte'));
      
      await tester.pump(); // Déclenche le submit
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle(); // Attend la fin du chargement et navigation

      expect(find.text('Vérifie ton email pour confirmer ton compte.'), findsOneWidget);
      expect(find.byType(SignUpScreen), findsNothing); // Vérifie le pop()
    });

    testWidgets('Shows error from Supabase', (tester) async {
      when(() => mockAuth.signUp(
            email: 'exists@example.com',
            password: 'password123',
          )).thenThrow(const AuthException('User already registered'));

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'exists@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Créer un compte'));
      await tester.pumpAndSettle();

      expect(find.text('User already registered'), findsOneWidget);
    });

    testWidgets('Password visibility toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());

      Finder getPasswordField() => find.byType(TextField).at(1);
      
      expect(tester.widget<TextField>(getPasswordField()).obscureText, isTrue);
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      expect(tester.widget<TextField>(getPasswordField()).obscureText, isFalse);
    });
  });
}

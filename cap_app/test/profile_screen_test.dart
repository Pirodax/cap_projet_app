import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/screens/profile_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// =============================================
// MOCKS
// =============================================

class MockProfileService extends Mock implements ProfileService {}
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  late MockProfileService mockProfileService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUser mockUser;

  setUp(() {
    mockProfileService = MockProfileService();
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');

    when(() => mockProfileService.getMutuelles()).thenAnswer((_) async => []);
    when(() => mockProfileService.getFormules()).thenAnswer((_) async => []);
    when(() => mockProfileService.getRegimes()).thenAnswer((_) async => []);
    when(() => mockProfileService.getUserProfile()).thenAnswer((_) async => null);
    when(() => mockProfileService.saveUserProfile(any())).thenAnswer((_) async {});
    when(() => mockProfileService.signOut()).thenAnswer((_) async {});
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: ProfileScreen(
        supabaseClient: mockSupabaseClient,
        profileService: mockProfileService,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('fr', 'FR')],
    );
  }

  // =============================================
  // TESTS
  // =============================================

  testWidgets('Affiche les informations utilisateur apres le chargement', (WidgetTester tester) async {
    final userData = {
      'username': 'John Doe',
      'date_of_birth': '1990-05-15',
      'mutuelle_id': 1,
      'mutuelle_formule_id': 2,
      'regime_assurance_maladie_id': 3,
    };
    final mutuelles = [Mutuelle(id: 1, name: 'Mutuelle A')];
    final formules = [Formule(id: 2, mutuelleId: 1, name: 'Formule B')];
    final regimes = [Regime(id: 3, name: 'Régime X')];

    when(() => mockProfileService.getUserProfile()).thenAnswer((_) async => userData);
    when(() => mockProfileService.getMutuelles()).thenAnswer((_) async => mutuelles);
    when(() => mockProfileService.getFormules()).thenAnswer((_) async => formules);
    when(() => mockProfileService.getRegimes()).thenAnswer((_) async => regimes);

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('15 mai 1990'), findsOneWidget);
    expect(find.text('Mutuelle A'), findsOneWidget);
    expect(find.text('Formule B'), findsOneWidget);
    expect(find.text('Régime X'), findsOneWidget);
  });

  testWidgets('Sauvegarde le profil lorsque le nom est modifie', (WidgetTester tester) async {
    when(() => mockProfileService.getUserProfile()).thenAnswer((_) async => {
      'username': 'Ancien Nom',
      'date_of_birth': '1990-01-01',
    });

    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Nouveau Nom');
    await tester.tap(find.text('Enregistrer les modifications'));
    await tester.pumpAndSettle();

    final expectedData = {
      'username': 'Nouveau Nom',
      'date_of_birth': '1990-01-01T00:00:00.000',
      'mutuelle_id': null,
      'mutuelle_formule_id': null,
      'regime_assurance_maladie_id': null,
    };

    verify(() => mockProfileService.saveUserProfile(expectedData)).called(1);

    expect(find.text('Profil mis à jour avec succès'), findsOneWidget);
  });
}

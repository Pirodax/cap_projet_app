import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:loodo_app/screens/profile_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

// =============================================
// MOCKS & FAKES
// =============================================

class MockProfileService extends Mock implements ProfileService {}
class MockSupabaseClient extends Mock implements MockSupabaseClientProxy {} 
class MockGoTrueClient extends Mock implements MockGoTrueClientProxy {} 
class MockUser extends Mock implements User {}

abstract class MockSupabaseClientProxy extends SupabaseClient {
  MockSupabaseClientProxy() : super('https://test.com', 'key');
}

abstract class MockGoTrueClientProxy extends GoTrueClient {
  MockGoTrueClientProxy() : super(url: '', headers: {});
}

class FakePostgrestFilterBuilder<T> extends Fake implements PostgrestFilterBuilder<T> {
  final T data;
  FakePostgrestFilterBuilder(this.data);

  @override
  Future<R> then<R>(FutureOr<R> Function(T) onValue, {Function? onError}) {
    return Future.value(data).then(onValue, onError: onError as FutureOr<R> Function(Object, StackTrace)?);
  }

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;

  @override
  PostgrestTransformBuilder<Map<String, dynamic>?> maybeSingle() =>
      FakePostgrestTransformBuilder<Map<String, dynamic>?>(
        data is List && (data as List).isNotEmpty ? (data as List).first : null
      );
}

class FakePostgrestTransformBuilder<T> extends Fake implements PostgrestTransformBuilder<T> {
  final T data;
  FakePostgrestTransformBuilder(this.data);

  @override
  Future<R> then<R>(FutureOr<R> Function(T) onValue, {Function? onError}) {
    return Future.value(data).then(onValue, onError: onError as FutureOr<R> Function(Object, StackTrace)?);
  }
}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final dynamic data;
  FakeSupabaseQueryBuilder(this.data);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select([String? columns]) =>
      FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(List<Map<String, dynamic>>.from(data as List));

  @override
  PostgrestFilterBuilder<Map<String, dynamic>> upsert(
    Object values, {
    String? onConflict,
    bool ignoreDuplicates = false,
    bool defaultToNull = false,
  }) => FakePostgrestFilterBuilder<Map<String, dynamic>>({});
}

void main() {
  late MockProfileService mockProfileService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late MockUser mockUser;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    registerFallbackValue(const <String, dynamic>{});
    await initializeDateFormatting('fr_FR', null);
    await Supabase.initialize(url: 'https://test.com', anonKey: 'key');
  });

  setUp(() {
    mockProfileService = MockProfileService();
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    mockUser = MockUser();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);
    when(() => mockUser.id).thenReturn('test-user-id');
    
    when(() => mockSupabaseClient.from(any())).thenAnswer((_) => FakeSupabaseQueryBuilder([]));

    when(() => mockProfileService.getMutuelles()).thenAnswer((_) async => []);
    when(() => mockProfileService.getFormules()).thenAnswer((_) async => []);
    when(() => mockProfileService.getRegimes()).thenAnswer((_) async => []);
    when(() => mockProfileService.getUserProfile()).thenAnswer((_) async => null);
    when(() => mockProfileService.saveUserProfile(any())).thenAnswer((_) async {});
    when(() => mockProfileService.signOut()).thenAnswer((_) async {});
  });

  Widget createTestWidget({ProfileService? service}) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfileScreen(
        supabaseClient: mockSupabaseClient,
        profileService: service ?? mockProfileService,
      ),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('fr', 'FR')],
    );
  }

  Future<void> setLargeDisplay(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 2400));
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    await tester.pump();
    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  group('Service & Models Coverage', () {
    test('Constructors', () {
      final m = Mutuelle(id: 1, name: 'M1');
      final f = Formule(id: 1, mutuelleId: 1, name: 'F1');
      final r = Regime(id: 1, name: 'R1');
      expect(m.id, 1);
      expect(f.mutuelleId, 1);
      expect(r.name, 'R1');
    });

    test('ProfileService Logic Paths', () async {
      final realService = ProfileService(mockSupabaseClient);

      when(() => mockSupabaseClient.from('mutuelles')).thenAnswer((_) => FakeSupabaseQueryBuilder([{'id': 1, 'name': 'M1'}]));
      await realService.getMutuelles();

      when(() => mockSupabaseClient.from('mutuelle_formules')).thenAnswer((_) => FakeSupabaseQueryBuilder([{'id': 1, 'mutuelle_id': 2, 'name': 'F1'}]));
      await realService.getFormules();

      when(() => mockSupabaseClient.from('assurance_maladie_regimes')).thenAnswer((_) => FakeSupabaseQueryBuilder([{'id': 1, 'name': 'R1'}]));
      await realService.getRegimes();

      when(() => mockSupabaseClient.from('user_infos')).thenAnswer((_) => FakeSupabaseQueryBuilder([{'username': 'test'}]));
      await realService.getUserProfile();

      when(() => mockGoTrueClient.currentUser).thenReturn(null);
      expect(await realService.getUserProfile(), isNull);
      expect(() => realService.saveUserProfile({}), throwsA(isA<AuthException>()));
    });
  });

  group('ProfileScreen UI Coverage', () {
    testWidgets('Default constructor and loader', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Mon Profil'), findsOneWidget);
    });

    testWidgets('Initialization error catch block', (tester) async {
      await setLargeDisplay(tester);
      when(() => mockProfileService.getMutuelles()).thenThrow(Exception('Init Fail'));
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Mon Profil'), findsOneWidget);
    });

    testWidgets('Full profile load and dropdown interaction', (tester) async {
      await setLargeDisplay(tester);
      final r1 = Regime(id: 100, name: 'RegA');
      final m1 = Mutuelle(id: 1, name: 'MutA');
      final f1 = Formule(id: 10, mutuelleId: 1, name: 'FormA');

      when(() => mockProfileService.getUserProfile()).thenAnswer((_) async => {
        'username': 'JohnDoe',
        'date_of_birth': '1995-10-25',
        'mutuelle_id': 1,
        'mutuelle_formule_id': 10,
        'regime_assurance_maladie_id': 100,
      });
      when(() => mockProfileService.getRegimes()).thenAnswer((_) async => [r1]);
      when(() => mockProfileService.getMutuelles()).thenAnswer((_) async => [m1]);
      when(() => mockProfileService.getFormules()).thenAnswer((_) async => [f1]);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('JohnDoe'), findsOneWidget);
      expect(find.text('25 octobre 1995'), findsOneWidget);

      await tester.ensureVisible(find.text('RegA'));
      await tester.tap(find.text('RegA'), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('RegA').last);
      await tester.pumpAndSettle();
    });

    testWidgets('Formula logic and null data scenarios', (tester) async {
      await setLargeDisplay(tester);
      final m1 = Mutuelle(id: 1, name: 'M1');
      final m2 = Mutuelle(id: 2, name: 'M2');
      final f1 = Formule(id: 10, mutuelleId: 1, name: 'F1');
      final f2 = Formule(id: 20, mutuelleId: 2, name: 'F2');

      when(() => mockProfileService.getMutuelles()).thenAnswer((_) async => [m1, m2]);
      when(() => mockProfileService.getFormules()).thenAnswer((_) async => [f1, f2]);
      when(() => mockProfileService.getUserProfile()).thenAnswer((_) async => {
        'username': null,
        'date_of_birth': null,
        'mutuelle_id': 1,
        'mutuelle_formule_id': 10,
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('JJ/MM/AAAA'), findsOneWidget);

      final m1Finder = find.text('M1');
      await tester.ensureVisible(m1Finder);
      await tester.tap(m1Finder, warnIfMissed: false);
      await tester.pumpAndSettle();
      
      final m2Finder = find.text('M2').last;
      await tester.tap(m2Finder);
      await tester.pumpAndSettle();
      expect(find.text('F1'), findsNothing);

      final formulaFinder = find.text('Ma formule');
      await tester.ensureVisible(formulaFinder);
      await tester.tap(formulaFinder, warnIfMissed: false);
      await tester.pumpAndSettle();
      
      final f2Finder = find.text('F2').last;
      await tester.tap(f2Finder);
      await tester.pumpAndSettle();
      
      final m2MainFinder = find.text('M2');
      await tester.ensureVisible(m2MainFinder);
      await tester.tap(m2MainFinder, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('M2').last);
      await tester.pumpAndSettle();
      expect(find.text('F2'), findsOneWidget);
    });

    testWidgets('DatePicker confirm and cancel', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final dateIcon = find.byIcon(Icons.cake_outlined);
      await tester.ensureVisible(dateIcon);
      await tester.tap(dateIcon, warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.textContaining(RegExp(r'OK|Valider|Confirmer', caseSensitive: false))); 
      await tester.pumpAndSettle();
      expect(find.text('JJ/MM/AAAA'), findsNothing);

      await tester.tap(dateIcon, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining(RegExp(r'Annuler|Quitter', caseSensitive: false)));
      await tester.pumpAndSettle();
    });

    testWidgets('Handles save and signout errors', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Test Erreur de Sauvegarde
      when(() => mockProfileService.saveUserProfile(any())).thenThrow(Exception('Save Fail'));
      final saveBtn = find.text('Enregistrer les modifications');
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      
      // On attend l'apparition de la première SnackBar
      await tester.pump(); 
      await tester.pump(const Duration(milliseconds: 500)); 
      expect(find.textContaining('Erreur'), findsWidgets);

      // IMPORTANT : On nettoie toutes les SnackBars avant le test suivant
      ScaffoldMessenger.of(tester.element(find.byType(ProfileScreen))).removeCurrentSnackBar();
      await tester.pumpAndSettle();

      // 2. Test Erreur de Déconnexion
      when(() => mockProfileService.signOut()).thenThrow(Exception('Logout Fail'));
      
      // On cible le bouton par son texte pour être sûr de l'action
      final logoutBtn = find.text('Se déconnecter');
      await tester.ensureVisible(logoutBtn);
      await tester.tap(logoutBtn);
      
      // On utilise pumpAndSettle pour attendre que l'animation de la SnackBar se termine
      // Si pumpAndSettle prend trop de temps (timeout), on utilisera des pump successifs
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      
      // Recherche plus large pour éviter les problèmes de caractères spéciaux ou de retour à la ligne
      expect(find.textContaining('déconnexion'), findsWidgets);
      
      // Vérification que le service a bien été appelé
      verify(() => mockProfileService.signOut()).called(1);
    });
   group('Models coverage', () {
      test('Mutuelle model', () {
        final m = Mutuelle(id: 1, name: 'Mut');
        expect(m.id, 1);
        expect(m.name, 'Mut');
      });
      test('Formule model', () {
        final f = Formule(id: 1, mutuelleId: 2, name: 'Form');
        expect(f.id, 1);
        expect(f.mutuelleId, 2);
        expect(f.name, 'Form');
      });
    });
  });
}

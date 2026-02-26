import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/screens/home_screen.dart';
import 'package:loodo_app/services/category_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:loodo_app/screens/category_details_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCategoryService extends Mock implements CategoryService {}

void main() {
  late MockCategoryService mockCategoryService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: 'https://test.com', anonKey: 'key');
  });

  setUp(() {
    mockCategoryService = MockCategoryService();
    when(() => mockCategoryService.getCategories()).thenAnswer((_) async => []);
  });

  Widget createTestWidget() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(categoryService: mockCategoryService),
    );
  }

  group('HomeScreen Coverage Tests', () {
    testWidgets('Displays categories when loading succeeds', (tester) async {
      final mockData = [
        {'id': 1, 'name': 'Dentaire', 'icon': '🦷'},
      ];
      when(() => mockCategoryService.getCategories()).thenAnswer((_) async => mockData);

      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Démarre le Future
      await tester.pumpAndSettle();

      expect(find.text('Dentaire'), findsOneWidget);
    });

    testWidgets('Displays error message when loading fails', (tester) async {
      when(() => mockCategoryService.getCategories())
          .thenAnswer((_) async => throw Exception('Erreur réseau'));

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.textContaining('Erreur'), findsOneWidget);
    });

    testWidgets('Navigates to CategoryDetailsScreen on tap', (tester) async {
      final mockData = [{'id': 1, 'name': 'Dentaire', 'icon': '🦷'}];
      when(() => mockCategoryService.getCategories()).thenAnswer((_) async => mockData);
      when(() => mockCategoryService.getDetailSoins(any())).thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dentaire'));
      await tester.pumpAndSettle();

      expect(find.byType(CategoryDetailsScreen), findsOneWidget);
    });

    testWidgets('Search overlay filters categories correctly', (tester) async {
      final mockData = [
        {'id': 1, 'name': 'Dentaire', 'icon': '🦷'},
        {'id': 2, 'name': 'Médecin', 'icon': '👨‍⚕️'},
      ];
      when(() => mockCategoryService.getCategories()).thenAnswer((_) async => mockData);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Activer la recherche
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Taper "Den"
      await tester.enterText(find.byType(TextField), 'Den');
      await tester.pump(const Duration(milliseconds: 100));

      // On vérifie que "Dentaire" est présent dans les résultats (ListTile blancs)
      // On utilise le style de texte blanc spécifique à l'overlay pour ne pas confondre avec le fond
      final resultFinder = find.ancestor(
        of: find.text('Dentaire'),
        matching: find.byType(ListTile),
      );
      expect(resultFinder, findsOneWidget);

      // On vérifie que "Médecin" n'est PAS présent dans les résultats (ListTile)
      final invalidResultFinder = find.ancestor(
        of: find.text('Médecin'),
        matching: find.byType(ListTile),
      );
      expect(invalidResultFinder, findsNothing);
    });
  });
}

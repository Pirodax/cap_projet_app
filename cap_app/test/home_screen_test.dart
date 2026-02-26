import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/screens/home_screen.dart';
import 'package:loodo_app/services/category_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:loodo_app/screens/category_details_screen.dart';

// Mock du service de catégories
class MockCategoryService extends Mock implements CategoryService {}

void main() {
  late MockCategoryService mockCategoryService;

  setUp(() {
    mockCategoryService = MockCategoryService();
  });

  // Helper pour créer le widget de test
  Widget createTestWidget() {
    return MaterialApp(
      home: HomeScreen(),
    );
  }

  // Comme HomeScreen crée son propre service en interne, on va devoir ruser
  // ou modifier HomeScreen pour accepter un service en paramètre. 
  // Mais pour l'instant, testons les éléments UI de base.

  group('HomeScreen Widget Tests', () {
    testWidgets('Displays app title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      expect(find.text('CAP PROJET'), findsOneWidget);
      expect(find.text('Ma mutuelle, mes avantages !'), findsOneWidget);
    });

    testWidgets('Search bar interactions', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

      final searchFinder = find.byType(TextField);
      expect(searchFinder, findsOneWidget);

      // Cliquer sur la barre de recherche active l'overlay
      await tester.tap(searchFinder);
      await tester.pumpAndSettle();

      expect(find.text('Que recherchez-vous ?'), findsOneWidget);

      // Taper du texte
      await tester.enterText(searchFinder, 'dentaire');
      await tester.pump();

      // Vérifier que le bouton clear apparaît
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Effacer la recherche
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      
      final textField = tester.widget<TextField>(searchFinder);
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('News section is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      
      expect(find.text('Actualités'), findsOneWidget);
      expect(find.text('Nouvelles mesures de remboursement'), findsOneWidget);
      expect(find.byIcon(Icons.article), findsWidgets);
    });
  });
}

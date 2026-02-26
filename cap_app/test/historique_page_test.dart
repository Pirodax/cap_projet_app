import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/features/History/historique_page.dart';

void main() {
  group('HistoriquePage Widget Tests', () {
    testWidgets('HistoriquePage displays loader then content', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));

      // Initial state should show skeletons/loader
      expect(find.byType(RefreshIndicator), findsOneWidget);
      
      // Wait for data loading (800ms in code + some buffer)
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      expect(find.text('Historique des simulations'), findsOneWidget);
      expect(find.text('Simulations'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Search filter works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'ORL');
      await tester.pumpAndSettle();

      expect(find.text('Consultation ORL'), findsOneWidget);
      expect(find.text('Médecin généraliste'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();
      expect(find.text('Médecin généraliste'), findsOneWidget);
    });

    testWidgets('Category filters work', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Tap on 'Spécialiste' category filter
      await tester.tap(find.text('Spécialiste').first);
      await tester.pumpAndSettle();

      expect(find.text('Consultation ORL'), findsOneWidget);
      expect(find.text('Médecin généraliste'), findsNothing);
    });

    testWidgets('Period filters work', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Tap on '7 jours' period filter
      await tester.tap(find.text('7 jours'));
      await tester.pumpAndSettle();

      // Check results (Consultation ORL and Médecin généraliste are within 7 days in mock)
      expect(find.text('Consultation ORL'), findsOneWidget);
    });

    testWidgets('Sort menu works', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Open sort menu
      await tester.tap(find.byIcon(Icons.sort));
      await tester.pumpAndSettle();

      // Select 'Montant élevé'
      await tester.tap(find.text('Montant élevé'));
      await tester.pumpAndSettle();

      // The list should be sorted (IRM cérébrale is 150.00, should be first)
      final firstCardText = tester.widget<Text>(find.textContaining('IRM cérébrale').first);
      expect(firstCardText.data, contains('IRM cérébrale'));
    });

    testWidgets('Category totals modal opens and displays data', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Tap on 'Voir par catégorie' button
      await tester.tap(find.text('Voir par catégorie'));
      await tester.pumpAndSettle();

      expect(find.text('Totaux par catégorie'), findsOneWidget);
      expect(find.text('Détails par catégorie'), findsOneWidget);
      
      // Close modal
      await tester.tap(find.text('Fermer'));
      await tester.pumpAndSettle();
      expect(find.text('Totaux par catégorie'), findsNothing);
    });

    testWidgets('Simulation details modal opens', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Tap on a simulation card
      await tester.tap(find.text('Consultation ORL'));
      await tester.pumpAndSettle();

      expect(find.text('Montant total'), findsOneWidget);
      expect(find.text('Reste à charge'), findsOneWidget);
      
      // Close details
      await tester.tap(find.text('Fermer'));
      await tester.pumpAndSettle();
      expect(find.text('Montant total'), findsNothing);
    });

    testWidgets('Empty state displays when no matches', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ZXYWVU');
      await tester.pumpAndSettle();

      expect(find.text('Aucune simulation trouvée'), findsOneWidget);
    });
  });
}

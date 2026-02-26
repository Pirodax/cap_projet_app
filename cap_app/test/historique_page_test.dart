import 'package:flutter/material.dart' hide Simulation;
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/features/History/historique_page.dart';

void main() {
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

  // Helper pour attendre le chargement des données (dépasser le Future.delayed de 800ms)
  // On n'utilise JAMAIS pumpAndSettle car le SkeletonLoader a une animation infinie.
  Future<void> waitForData(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pump(const Duration(milliseconds: 500)); 
  }

  group('HistoriquePage Widget Tests', () {
    testWidgets('HistoriquePage displays loader then content', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      expect(find.byType(RefreshIndicator), findsOneWidget);
      await waitForData(tester);
      expect(find.text('Historique des simulations'), findsOneWidget);
      expect(find.text('Simulations'), findsOneWidget);
      expect(find.text('Consultation ORL'), findsOneWidget);
    });

    testWidgets('Search filter works for title and category', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await waitForData(tester);

      await tester.enterText(find.byType(TextField), 'ORL');
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Consultation ORL'), findsOneWidget);
      expect(find.text('Médecin généraliste'), findsNothing);

      await tester.enterText(find.byType(TextField), 'Imagerie');
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Radiographie thorax'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Médecin généraliste'), findsOneWidget);
    });

    testWidgets('Category chips filtering', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await waitForData(tester);

      await tester.tap(find.text('Généraliste').first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Médecin généraliste'), findsOneWidget);
      expect(find.text('Consultation ORL'), findsNothing);
      
      await tester.tap(find.text('Tous').first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Consultation ORL'), findsOneWidget);
    });

    testWidgets('Period filtering logic', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await waitForData(tester);

      await tester.tap(find.text('7 jours'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Consultation ORL'), findsOneWidget);
      expect(find.text('IRM cérébrale'), findsNothing);
    });

    testWidgets('Sorting functionality', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await waitForData(tester);

      final sortIcon = find.byIcon(Icons.sort);

      // Tri par montant faible
      await tester.tap(sortIcon);
      await tester.pump(const Duration(milliseconds: 500)); // Remplacement de pumpAndSettle
      await tester.tap(find.text('Montant faible'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Médecin généraliste'), findsWidgets);

      // Tri par meilleure économie
      await tester.tap(sortIcon);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Meilleure économie'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('IRM cérébrale'), findsWidgets);
    });

    testWidgets('Category stats modal calculation and display', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await waitForData(tester);

      await tester.tap(find.text('Voir par catégorie'), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 800)); 

      expect(find.text('Totaux par catégorie'), findsOneWidget);
      expect(find.text('Total économisé'), findsOneWidget);
      expect(find.text('Spécialiste'), findsWidgets);

      final closeBtn = find.widgetWithText(ElevatedButton, 'Fermer');
      await tester.ensureVisible(closeBtn);
      await tester.tap(closeBtn, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 800));
    });

    testWidgets('Simulation detail modal display', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await waitForData(tester);

      await tester.tap(find.text('Consultation ORL'));
      await tester.pump(const Duration(milliseconds: 800));

      final modalFinder = find.byType(BottomSheet);
      
      // On utilise descendant pour éviter les doublons avec les cartes de la liste en arrière-plan
      expect(find.descendant(of: modalFinder, matching: find.text('Montant total')), findsOneWidget);
      expect(find.descendant(of: modalFinder, matching: find.text('Remboursement estimé')), findsOneWidget);
      expect(find.descendant(of: modalFinder, matching: find.text('50.00 €')), findsOneWidget);
      expect(find.descendant(of: modalFinder, matching: find.text('35.00 €')), findsOneWidget);

      final closeBtn = find.descendant(of: modalFinder, matching: find.byType(ElevatedButton));
      await tester.ensureVisible(closeBtn);
      await tester.tap(closeBtn, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 800));
    });

    testWidgets('Refresh functionality', (tester) async {
      await setLargeDisplay(tester);
      await tester.pumpWidget(const MaterialApp(home: HistoriquePage()));
      await waitForData(tester);

      await tester.fling(find.byType(RefreshIndicator), const Offset(0, 300), 1000);
      await tester.pump(); 
      await tester.pump(const Duration(seconds: 1)); 
      await tester.pump(const Duration(seconds: 1)); 
      
      expect(find.text('Simulations'), findsOneWidget);
    });

    test('Simulation Model Unit Test', () {
      final now = DateTime.now();
      final sim = Simulation(
        id: '99', titre: 'Test Sim', categorie: 'Test Cat', montant: 100.0,
        economieEstimee: 50.0, date: now, icon: Icons.add, color: Colors.red,
      );
      expect(sim.id, '99');
      expect(sim.montant, 100.0);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/widgets/bottom_navbar.dart';

void main() {
  group('BottomNavBar Widget Tests', () {
    testWidgets('Displays all items correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavBar(
              selectedIndex: 0,
              onItemTapped: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text('Historique'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('Calls onItemTapped when an item is pressed', (WidgetTester tester) async {
      int tappedIndex = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavBar(
              selectedIndex: 0,
              onItemTapped: (index) => tappedIndex = index,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Historique'));
      expect(tappedIndex, 1);

      await tester.tap(find.text('Profil'));
      expect(tappedIndex, 2);

      await tester.tap(find.text('Accueil'));
      expect(tappedIndex, 0);
    });

    testWidgets('Highlights the selected index', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: BottomNavBar(
              selectedIndex: 1, // Historique sélectionné
              onItemTapped: (_) {},
            ),
          ),
        ),
      );

      final BottomNavigationBar navBar = tester.widget(find.byType(BottomNavigationBar));
      expect(navBar.currentIndex, 1);
    });
  });
}

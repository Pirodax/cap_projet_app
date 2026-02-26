import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/screens/category_details_screen.dart';
import 'package:loodo_app/screens/soin_detail_screen.dart';
import 'package:loodo_app/services/category_service.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryService extends Mock implements CategoryService {}

void main() {
  late MockCategoryService mockCategoryService;

  setUp(() {
    mockCategoryService = MockCategoryService();
    // Stub par défaut
    when(() => mockCategoryService.getDetailSoins(any()))
        .thenAnswer((_) async => []);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: CategoryDetailsScreen(
        categoryId: 1,
        categoryName: 'Dentaire',
        categoryIcon: '🦷',
        categoryService: mockCategoryService,
      ),
    );
  }

  group('CategoryDetailsScreen Tests', () {
    testWidgets('Displays soins when loading succeeds', (tester) async {
      final mockSoins = [
        {'id': 1, 'name': 'Détartrage', 'brss': 28.92, 'detail': 'Soin de base'},
        {'id': 2, 'name': 'Carie', 'brss': 50.0, 'detail': 'Traitement'},
      ];

      when(() => mockCategoryService.getDetailSoins(any()))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 50));
            return mockSoins;
          });

      await tester.pumpWidget(createTestWidget());
      
      // On déclenche le chargement
      await tester.pump(); 
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // On attend la fin du chargement
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Détartrage'), findsOneWidget);
      expect(find.text('Carie'), findsOneWidget);
      // Utilisation de RegExp pour être flexible sur le format (50, 50.0, 50.00)
      expect(find.textContaining(RegExp(r'28.92')), findsOneWidget);
      expect(find.textContaining(RegExp(r'50')), findsOneWidget);
    });

    testWidgets('Displays error message when loading fails', (tester) async {
      when(() => mockCategoryService.getDetailSoins(any()))
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 50));
            throw Exception('Erreur base de données');
          });

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Erreur'), findsOneWidget);
      expect(find.textContaining('Erreur base de données'), findsOneWidget);
    });

    testWidgets('Navigates to SoinDetailScreen on tap', (tester) async {
      final mockSoins = [
        {'id': 1, 'name': 'Détartrage', 'brss': 28.92, 'detail': 'Soin de base'},
      ];

      when(() => mockCategoryService.getDetailSoins(any()))
          .thenAnswer((_) async => mockSoins);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Détartrage'));
      await tester.pumpAndSettle();

      expect(find.byType(SoinDetailScreen), findsOneWidget);
    });
  });
}

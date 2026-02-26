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
          .thenAnswer((_) async => mockSoins);

      await tester.pumpWidget(createTestWidget());
      
      // État de chargement
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle();

      expect(find.text('Détartrage'), findsOneWidget);
      expect(find.text('Carie'), findsOneWidget);
      expect(find.text('28.92 €'), findsOneWidget);
      expect(find.text('50 €'), findsOneWidget);
    });

    testWidgets('Displays error message when loading fails', (tester) async {
      when(() => mockCategoryService.getDetailSoins(any()))
          .thenThrow(Exception('Erreur base de données'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Erreur'), findsOneWidget);
      expect(find.textContaining('Erreur base de données'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('Displays empty message when no soins found', (tester) async {
      when(() => mockCategoryService.getDetailSoins(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Aucun soin disponible'), findsOneWidget);
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
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

      // Vérifie que l'écran de destination est bien SoinDetailScreen
      expect(find.byType(SoinDetailScreen), findsOneWidget);
      expect(find.text('Détails du soin'), findsOneWidget);
      expect(find.text('Détartrage'), findsOneWidget);
    });

    testWidgets('AppBar shows correct icon and name', (tester) async {
      when(() => mockCategoryService.getDetailSoins(any()))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestWidget());
      
      expect(find.text('🦷'), findsOneWidget);
      expect(find.text('Dentaire'), findsOneWidget);
    });
  });
}

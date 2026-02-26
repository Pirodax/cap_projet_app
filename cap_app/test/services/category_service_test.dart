import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/services/category_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// =============================================
// MOCKS & FAKES POUR SUPABASE
// =============================================

class MockSupabaseClient extends Mock implements SupabaseClient {}

class FakePostgrestFilterBuilder<T> extends Fake implements PostgrestFilterBuilder<T> {
  final T data;
  FakePostgrestFilterBuilder(this.data);

  @override
  Future<R> then<R>(FutureOr<R> Function(T) onValue, {Function? onError}) {
    return Future.value(data).then(onValue, onError: onError as FutureOr<R> Function(Object, StackTrace)?);
  }

  @override
  PostgrestFilterBuilder<T> eq(String column, Object value) => this;
}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final dynamic data;
  FakeSupabaseQueryBuilder(this.data);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select([String? columns]) =>
      FakePostgrestFilterBuilder<List<Map<String, dynamic>>>(List<Map<String, dynamic>>.from(data as List));
}

void main() {
  late MockSupabaseClient mockSupabase;
  late CategoryService service;

  setUp(() {
    mockSupabase = MockSupabaseClient();
    service = CategoryService(mockSupabase);
  });

  group('CategoryService Tests', () {
    test('getCategories returns data on success', () async {
      final mockData = [
        {'id': 1, 'name': 'Dentaire', 'icon': '🦷'},
        {'id': 2, 'name': 'Optique', 'icon': '👓'},
      ];

      when(() => mockSupabase.from('categories_soins'))
          .thenReturn(FakeSupabaseQueryBuilder(mockData));

      final result = await service.getCategories();

      expect(result.length, 2);
      expect(result[0]['name'], 'Dentaire');
      expect(result[1]['icon'], '👓');
    });

    test('getCategories returns empty list on error', () async {
      when(() => mockSupabase.from('categories_soins')).thenThrow(Exception('DB Error'));

      final result = await service.getCategories();

      expect(result, isEmpty);
    });

    test('getDetailSoins returns soins for a category', () async {
      final mockSoins = [
        {'id': 10, 'name': 'Consultation', 'brss': 25.0, 'detail': 'Test'},
      ];

      when(() => mockSupabase.from('soins'))
          .thenReturn(FakeSupabaseQueryBuilder(mockSoins));

      final result = await service.getDetailSoins(1);

      expect(result.length, 1);
      expect(result[0]['name'], 'Consultation');
      expect(result[0]['brss'], 25.0);
    });

    test('getDetailSoins returns empty list on error', () async {
      when(() => mockSupabase.from('soins')).thenThrow(Exception('Query Error'));

      final result = await service.getDetailSoins(99);

      expect(result, isEmpty);
    });
  });
}

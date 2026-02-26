import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase/supabase_init.dart';

class CategoryService {
  final SupabaseClient _supabase;

  CategoryService([SupabaseClient? client]) : _supabase = client ?? supabase;

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _supabase
          .from('categories_soins')
          .select('id, name, icon, created_at');

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDetailSoins(int categoryId) async {
    try {
      final response = await _supabase
          .from('soins')
          .select('id, name, brss, detail')
          .eq('categorie_id', categoryId);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      print('Error fetching soins: $e');
      return [];
    }
  }
}

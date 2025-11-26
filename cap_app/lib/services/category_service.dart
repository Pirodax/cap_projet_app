
import '../core/supabase/supabase_init.dart';

class CategoryService {
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      //final user = supabase.auth.currentUser;


      final response = await supabase
          .from('categories_soins')
          .select('id, name, icon, created_at');
      //.eq('user_id', user.id);

      return List<Map<String, dynamic>>.from(response);

    } catch (e) {
      // Gérer l'erreur, par exemple, en la journalisant ou en la lançant à nouveau
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getDetailSoins(int categoryId) async {
    try {
      final response = await supabase
          .from('soins')
          .select('id, name, brss, detail, icon')
          .eq('categorie_id', categoryId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching soins: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchSoins(String query) async {
    try {
      final response = await supabase
          .from('soins')
          .select('id, name, categorie_id, categories_soins(name, icon)')
          .ilike('name', '%$query%');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error searching soins: $e');
      return [];
    }
  }
}

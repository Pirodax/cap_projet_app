import 'package:flutter_test/flutter_test.dart';
import 'package:loodo_app/core/supabase/supabase_init.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Nécessaire pour simuler le stockage local de Supabase
    SharedPreferences.setMockInitialValues({});
  });

  group('Supabase Initialization Tests', () {
    test('initSupabase completes without error', () async {
      // On teste que l'appel ne jette pas d'exception
      expect(initSupabase(), completes);
    });

    test('supabase getter returns a client instance', () async {
      // Une fois initialisé, le getter doit renvoyer le client
      final client = supabase;
      expect(client, isA<SupabaseClient>());
    });
  });
}

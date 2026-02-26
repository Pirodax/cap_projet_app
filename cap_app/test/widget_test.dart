import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loodo_app/app.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // Simule SharedPreferences pour Supabase
    SharedPreferences.setMockInitialValues({});
    
    // Initialise Supabase avec des valeurs bidon pour les tests
    await Supabase.initialize(
      url: 'https://test.com',
      anonKey: 'key',
    );
  });

  testWidgets('App starts without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

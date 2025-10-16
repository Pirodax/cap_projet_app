import 'package:flutter/material.dart';
import 'app.dart';
import 'core/supabase/supabase_init.dart';

Future<void> main() async {
  // Assure que le framework Flutter est prêt.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialise Supabase
  await initSupabase();
  // Lance l'application
  runApp(const MyApp());
}

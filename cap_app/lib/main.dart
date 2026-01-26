import 'package:flutter/material.dart';
import 'app.dart';
import 'core/supabase/supabase_init.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initSupabase();
  runApp(const MyApp());
}

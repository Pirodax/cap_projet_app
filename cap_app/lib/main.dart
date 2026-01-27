import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/supabase/supabase_init.dart';

Future<void> main() async {
  // Assure que le framework Flutter est prêt
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase pour deployment web
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialise Supabase
  await initSupabase();

  // Lance l'application
  runApp(const MyApp());
}

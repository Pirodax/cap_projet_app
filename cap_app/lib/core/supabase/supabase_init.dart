import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initSupabase() async {
  await Supabase.initialize(
    url: 'https://aodcnrzahiqzryjjdrby.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvZGNucnphaGlxenJ5ampkcmJ5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1OTk3MzgsImV4cCI6MjA3NjE3NTczOH0.L9Q37WRN3bumHmB-MjyB9F4bnnUIe8GjJv6dzSE41yE',
  );
}

// Utiliser un getter est beaucoup plus sûr pour éviter les crashs au démarrage
SupabaseClient get supabase => Supabase.instance.client;

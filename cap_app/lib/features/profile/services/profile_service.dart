import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/formule.dart';
import '../models/mutuelle.dart';
import '../models/regime.dart';

class ProfileService {
  final supabase = Supabase.instance.client;

  Future<List<Mutuelle>> getMutuelles() async {
    final response = await supabase.from('mutuelles').select('id, name');
    return (response as List)
        .map((item) => Mutuelle(id: item['id'], name: item['name']))
        .toList();
  }

  Future<List<Formule>> getFormules() async {
    final response = await supabase.from('mutuelle_formules').select('id, mutuelle_id, name');
    return (response as List)
        .map((item) => Formule(id: item['id'], mutuelleId: item['mutuelle_id'], name: item['name']))
        .toList();
  }

  Future<List<Regime>> getRegimes() async {
    try {
      final response = await supabase.from('assurance_maladie_regimes').select('id, name');
      return (response as List)
          .map((item) => Regime(id: item['id'], name: item['name']))
          .toList();
    } catch (e) {
      debugPrint('Erreur récupération régimes: $e');
      return [];
    }
  }
}
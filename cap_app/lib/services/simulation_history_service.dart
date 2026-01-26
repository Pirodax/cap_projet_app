import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/simulation_history.dart';

class SimulationHistoryService {
  final _supabase = Supabase.instance.client;

  /// Save a simulation to history
  Future<void> saveSimulation({
    required int soinId,
    required String soinName,
    String? soinIcon,
    String? categorieName,
    required double prixFacture,
    required double brss,
    required double tauxSecu,
    required double remboursementSecu,
    required double remboursementMutuelle,
    required double participationForfaitaire,
    required double totalAutoriseMutuelle,
    required double totalRembourse,
    required double resteACharge,
    required double montantDepassement,
    required bool estConventionne,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    await _supabase.from('simulation_history').insert({
      'user_id': userId,
      'soin_id': soinId,
      'soin_name': soinName,
      'soin_icon': soinIcon,
      'categorie_name': categorieName,
      'prix_facture': prixFacture,
      'brss': brss,
      'taux_secu': tauxSecu,
      'remboursement_secu': remboursementSecu,
      'remboursement_mutuelle': remboursementMutuelle,
      'participation_forfaitaire': participationForfaitaire,
      'total_autorise_mutuelle': totalAutoriseMutuelle,
      'total_rembourse': totalRembourse,
      'reste_a_charge': resteACharge,
      'montant_depassement': montantDepassement,
      'est_conventionne': estConventionne,
    });
  }

  /// Get all simulations for the current user, ordered by date desc
  Future<List<SimulationHistory>> getSimulations() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('simulation_history')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => SimulationHistory.fromJson(json))
        .toList();
  }

  /// Delete a simulation by id
  Future<void> deleteSimulation(int id) async {
    await _supabase.from('simulation_history').delete().eq('id', id);
  }
}

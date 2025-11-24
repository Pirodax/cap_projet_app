import '../core/supabase/supabase_init.dart';
import '../models/remboursement_result.dart';
import 'dart:math';

class RemboursementService {
  final _supabase = supabase;

  // Fonction principale de calcul
  Future<RemboursementResult> calculerRemboursement({
    required String userId,
    required int soinId,
    required double prixReel,
  }) async {
    try {
      // On récupère le profil utilisateur
      final userResponse = await _supabase
          .from('user_infos')
          .select('regime_assurance_maladie_id, mutuelle_formule_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (userResponse == null) {
        return RemboursementResult(
          success: false,
          error: 'Profil utilisateur non trouvé',
        );
      }

      final regimeId = userResponse['regime_assurance_maladie_id'];
      final formuleId = userResponse['mutuelle_formule_id'];

      if (regimeId == null || formuleId == null) {
        return RemboursementResult(
          success: false,
          error: 'Complétez votre profil (mutuelle et régime)',
        );
      }

      // On récupère le soin
      final soinResponse = await _supabase
          .from('soins')
          .select('name, brss, categorie_id')
          .eq('id', soinId)
          .single();

      final soinName = soinResponse['name'];
      final brss = (soinResponse['brss'] as num).toDouble();
      final categorieId = soinResponse['categorie_id'];

      // On récupère le taux de Sécu
      final secuResponse = await _supabase
          .from('assurance_maladie_remboursements')
          .select('taux_assurance_maladie')
          .eq('soins_id', soinId)
          .eq('regimes_id', regimeId)
          .maybeSingle();

      if (secuResponse == null) {
        return RemboursementResult(
          success: false,
          error: 'Remboursement Sécu non disponible',
        );
      }

      final tauxSecu = (secuResponse['taux_assurance_maladie'] as num).toDouble();

      // Calcul Sécu
      final rembSecuBrut = brss * (tauxSecu / 100);

      double participationForfaitaire = 0;
      if (categorieId == 1 && tauxSecu > 0) {
        participationForfaitaire = 2.0;
      }

      final rembSecuNet = rembSecuBrut - participationForfaitaire;

      // On récupère le taux de la Mutuelle
      final mutuelleResponse = await _supabase
          .from('mutuelle_formule_details_remboursement')
          .select('taux_mutuelle, type')
          .eq('formule_id', formuleId)
          .eq('detail_soins_id', soinId)
          .maybeSingle();

      double rembMutuelle = 0;
      double tauxMutuelle = 0;

      if (mutuelleResponse != null) {
        tauxMutuelle = (mutuelleResponse['taux_mutuelle'] as num).toDouble();
        final type = mutuelleResponse['type'];

        if (type == 'pourcentage') {
          final totalBR = brss * (tauxMutuelle / 100);
          rembMutuelle = totalBR - rembSecuBrut;
        } else if (type == 'euro') {
          rembMutuelle = min(tauxMutuelle, prixReel - rembSecuNet);
        }
        rembMutuelle = max(0.0, min(rembMutuelle, prixReel - rembSecuNet));
      }

      // Calcul final
      final totalRembourse = rembSecuNet + rembMutuelle;
      final resteACharge = max(0.0, prixReel - totalRembourse);

      return RemboursementResult(
        success: true,
        details: RemboursementDetails(
          prixReel: prixReel,
          baseRemboursement: brss,
          tauxSecu: tauxSecu,
          rembSecuBrut: rembSecuBrut,
          participationForfaitaire: participationForfaitaire,
          rembSecuNet: rembSecuNet,
          tauxMutuelle: tauxMutuelle,
          rembMutuelle: rembMutuelle,
          totalRembourse: totalRembourse,
          resteACharge: resteACharge,
          soinName: soinName,
        ),
      );
    } catch (e) {
      print('Erreur calcul: $e');
      return RemboursementResult(
        success: false,
        error: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Fonction pour récupérer la liste des soins
  Future<List<Map<String, dynamic>>> getSoins() async {
    try {
      final response = await _supabase
          .from('soins')
          .select('id, name, brss')
          .order('name');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Erreur chargement soins: $e');
      return [];
    }
  }
}

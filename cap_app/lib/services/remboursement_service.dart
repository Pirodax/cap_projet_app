import '../core/supabase/supabase_init.dart';
import '../models/remboursement_result.dart';
import 'dart:math';

class RemboursementService {
  final _supabase = supabase;

  Future<RemboursementResult> calculerRemboursement({
    required String userId,
    required int soinId,
    required double prixReel,
  }) async {
    try {
      // Récupère le profil utilisateur
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

      if (regimeId == null) {
        return RemboursementResult(
          success: false,
          error: 'Complétez votre profil (régime)',
        );
      }

      // Récupère le soin
      final soinResponse = await _supabase
          .from('soins')
          .select('id, name, brss, categorie_id')
          .eq('id', soinId)
          .maybeSingle();

      if (soinResponse == null) {
        return RemboursementResult(
          success: false,
          error: 'Soin non trouvé',
        );
      }

      final soinName = soinResponse['name'] as String;
      final brss = (soinResponse['brss'] as num).toDouble();
      final categorieId = soinResponse['categorie_id'] as int;

      // Cherche le taux Sécu
      var secuResponse = await _supabase
          .from('assurance_maladie_remboursements')
          .select('taux_assurance_maladie')
          .eq('soins_id', soinId)
          .eq('regimes_id', regimeId)
          .maybeSingle();

      if (secuResponse == null) {
        final soinsMemeNom = await _supabase
            .from('soins')
            .select('id')
            .eq('name', soinName);

        for (var s in soinsMemeNom) {
          secuResponse = await _supabase
              .from('assurance_maladie_remboursements')
              .select('taux_assurance_maladie')
              .eq('soins_id', s['id'])
              .eq('regimes_id', regimeId)
              .maybeSingle();

          if (secuResponse != null) break;
        }
      }

      double tauxSecu;
      if (secuResponse != null) {
        tauxSecu = (secuResponse['taux_assurance_maladie'] as num).toDouble();
      } else {
        tauxSecu = _getTauxDefautParCategorie(categorieId);
      }

      // Calcul Sécu
      final rembSecuBrut = brss * (tauxSecu / 100);

      // Participation forfaitaire (jamais remboursée)
      double participationForfaitaire = 0;
      if (categorieId == 1 && tauxSecu > 0) {
        participationForfaitaire = 1.0;
      }

      final rembSecuNet = max(0.0, rembSecuBrut - participationForfaitaire);

      // Détecte si conventionné ou non
      bool estConventionne = prixReel <= brss;

      // Récupère le taux Mutuelle
      double rembMutuelle = 0;
      double tauxMutuelle = 0;

      if (formuleId != null) {
        final mutuelleResponse = await _supabase
            .from('mutuelle_remboursements')
            .select('type, taux_mutuelle_conventionne, taux_mutuelle_non_conventionne, forfait_conventionne, forfait_non_conventionne')
            .eq('formule_id', formuleId)
            .eq('soins_id', soinId)
            .maybeSingle();

        if (mutuelleResponse != null) {
          final type = mutuelleResponse['type'] as String?;

          if (type == 'pourcentage') {
            if (estConventionne) {
              tauxMutuelle = (mutuelleResponse['taux_mutuelle_conventionne'] as num?)?.toDouble() ?? 0;
            } else {
              tauxMutuelle = (mutuelleResponse['taux_mutuelle_non_conventionne'] as num?)?.toDouble() ?? 0;
            }

            final totalMutuelleBRSS = brss * (tauxMutuelle / 100);
            rembMutuelle = totalMutuelleBRSS - rembSecuBrut;

          } else if (type == 'forfait') {
            if (estConventionne) {
              rembMutuelle = (mutuelleResponse['forfait_conventionne'] as num?)?.toDouble() ?? 0;
            } else {
              rembMutuelle = (mutuelleResponse['forfait_non_conventionne'] as num?)?.toDouble() ?? 0;
            }
          }

          // La mutuelle ne rembourse pas la participation forfaitaire
          // Elle rembourse max le prix - sécu net - participation forfaitaire
          final maxRemboursableMutuelle = prixReel - rembSecuNet - participationForfaitaire;
          rembMutuelle = max(0.0, min(rembMutuelle, maxRemboursableMutuelle));
        }
      }

      // Calcul final
      // Le reste à charge inclut toujours la participation forfaitaire
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

  double _getTauxDefautParCategorie(int categorieId) {
    switch (categorieId) {
      case 1: return 70.0;
      case 2: return 80.0;
      case 3: return 60.0;
      case 4: return 60.0;
      case 5: return 60.0;
      case 6: return 100.0;
      case 7: return 60.0;
      case 8: return 60.0;
      case 9: return 65.0;
      default: return 70.0;
    }
  }

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
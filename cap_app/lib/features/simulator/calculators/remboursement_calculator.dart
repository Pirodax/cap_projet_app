import '../models/remboursement_info.dart';
import '../models/remboursement_result.dart';

class RemboursementCalculator {
  static RemboursementResult calculer(RemboursementInfo info) {
    // 1. Déterminer si le praticien est conventionné
    final bool estConventionne = info.prixFacture <= info.brss;
    final double montantDepassement = info.prixFacture > info.brss ? info.prixFacture - info.brss : 0;

    double totalAutoriseMutuelle = 0;

    if (info.typeMutuelle == 'pourcentage') {
      final double taux = estConventionne
          ? (info.tauxMutuelleConventionne ?? 0)
          : (info.tauxMutuelleNonConventionne ?? 0);

      totalAutoriseMutuelle = info.brss * (taux / 100);
    }

    // 2. Calculer le remboursement Sécurité sociale
    double remboursementSecu = info.brss * (info.tauxSecu / 100);

    // 3. Calculer la participation forfaitaire (1€ si majeur)
    final double participationForfaitaire = info.isMajeur ? 1.00 : 0.00;

    // 4. Déduire la participation forfaitaire du remboursement Sécu
    remboursementSecu = remboursementSecu - participationForfaitaire;
    if (remboursementSecu < 0) remboursementSecu = 0;

    // 5. Calculer le remboursement Mutuelle selon le type
    double remboursementMutuelle = _calculerRemboursementMutuelle(
      info: info,
      estConventionne: estConventionne,
    );

    // Cas mutuelle en pourcentage : le taux représente le TOTAL autorisé
    if (info.typeMutuelle == 'pourcentage') {
      remboursementMutuelle = remboursementMutuelle - remboursementSecu;
      if (remboursementMutuelle < 0) remboursementMutuelle = 0;
    }

    final double maxRemboursable = info.prixFacture - remboursementSecu;

    if (remboursementMutuelle > maxRemboursable) {
      remboursementMutuelle = maxRemboursable < 0 ? 0 : maxRemboursable;
    }

    // 6. Calculer le total remboursé et le reste à charge
    final double totalRembourse = remboursementSecu + remboursementMutuelle;
    double resteACharge = info.prixFacture - totalRembourse;
    if (resteACharge < 0) resteACharge = 0;

    return RemboursementResult(
      remboursementSecu: remboursementSecu,
      totalAutoriseMutuelle: totalAutoriseMutuelle,
      remboursementMutuelle: remboursementMutuelle,
      participationForfaitaire: participationForfaitaire,
      totalRembourse: totalRembourse,
      resteACharge: resteACharge,
      montantDepassement: montantDepassement,
      estConventionne: estConventionne,
    );
  }

  static double _calculerRemboursementMutuelle({
    required RemboursementInfo info,
    required bool estConventionne,
  }) {
    switch (info.typeMutuelle) {
      case 'pourcentage':
        final double taux = estConventionne
            ? (info.tauxMutuelleConventionne ?? 0)
            : (info.tauxMutuelleNonConventionne ?? 0);
        return info.brss * (taux / 100);

      case 'forfait':
        final double forfait = estConventionne
            ? (info.forfaitConventionne ?? 0)
            : (info.forfaitNonConventionne ?? 0);
        return forfait;

      case 'forfait_annuel':
        final double taux = estConventionne
            ? (info.tauxMutuelleConventionne ?? 0)
            : (info.tauxMutuelleNonConventionne ?? 0);
        final double forfait = estConventionne
            ? (info.forfaitConventionne ?? 0)
            : (info.forfaitNonConventionne ?? 0);
        return (info.brss * (taux / 100)) + forfait;

      default:
        return 0;
    }
  }

  static String getLabelMutuelle({
    required String typeMutuelle,
    required bool estConventionne,
    double? tauxConventionne,
    double? tauxNonConventionne,
  }) {
    if (typeMutuelle == 'forfait') {
      return 'Mutuelle (forfait)';
    } else if (typeMutuelle == 'forfait_annuel') {
      return 'Mutuelle (% + forfait)';
    } else {
      final double taux = estConventionne
          ? (tauxConventionne ?? 0)
          : (tauxNonConventionne ?? 0);
      return 'Mutuelle (${taux.toStringAsFixed(0)}%)';
    }
  }
}

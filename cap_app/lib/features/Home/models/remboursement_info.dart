// models/remboursement_info.dart

/// Modèle contenant toutes les informations nécessaires pour calculer un remboursement
class RemboursementInfo {
  // Données du soin
  final double brss;
  final double tauxSecu;
  final String typeMutuelle;

  // Données de la mutuelle
  final double? tauxMutuelleConventionne;
  final double? tauxMutuelleNonConventionne;
  final double? forfaitConventionne;
  final double? forfaitNonConventionne;

  // Données utilisateur
  final bool isMajeur;
  final double prixFacture;

  RemboursementInfo({
    required this.brss,
    required this.tauxSecu,
    required this.typeMutuelle,
    this.tauxMutuelleConventionne,
    this.tauxMutuelleNonConventionne,
    this.forfaitConventionne,
    this.forfaitNonConventionne,
    required this.isMajeur,
    required this.prixFacture,
  });
}

/// Résultat d'un calcul de remboursement
class RemboursementResult {
  final double remboursementSecu;
  final double remboursementMutuelle;
  final double participationForfaitaire;
  final double totalRembourse;
  final double resteACharge;
  final double montantDepassement;
  final bool estConventionne;

  RemboursementResult({
    required this.remboursementSecu,
    required this.remboursementMutuelle,
    required this.participationForfaitaire,
    required this.totalRembourse,
    required this.resteACharge,
    required this.montantDepassement,
    required this.estConventionne,
  });

  /// Pourcentage de prise en charge
  double get pourcentagePriseEnCharge {
    if (resteACharge == 0) return 100.0;
    return (totalRembourse / (resteACharge + totalRembourse)) * 100;
  }
}
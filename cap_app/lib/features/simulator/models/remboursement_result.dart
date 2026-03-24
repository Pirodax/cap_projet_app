/// Résultat d'un calcul de remboursement
class RemboursementResult {
  final double remboursementSecu;
  final double totalAutoriseMutuelle;
  final double remboursementMutuelle;
  final double participationForfaitaire;
  final double totalRembourse;
  final double resteACharge;
  final double montantDepassement;
  final bool estConventionne;

  RemboursementResult({
    required this.remboursementSecu,
    required this.totalAutoriseMutuelle,
    required this.remboursementMutuelle,
    required this.participationForfaitaire,
    required this.totalRembourse,
    required this.resteACharge,
    required this.montantDepassement,
    required this.estConventionne,
  });

  double get pourcentagePriseEnCharge {
    if (resteACharge == 0) return 100.0;
    return (totalRembourse / (resteACharge + totalRembourse)) * 100;
  }
}

/// Modèle contenant toutes les informations nécessaires pour calculer un remboursement
class RemboursementInfo {
  final double brss;
  final double tauxSecu;
  final String typeMutuelle;
  final double? tauxMutuelleConventionne;
  final double? tauxMutuelleNonConventionne;
  final double? forfaitConventionne;
  final double? forfaitNonConventionne;
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

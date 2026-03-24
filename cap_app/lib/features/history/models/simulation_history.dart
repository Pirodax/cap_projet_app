class SimulationHistory {
  final int id;
  final String soinName;
  final String? soinIcon;
  final String? categorieName;
  final double prixFacture;
  final double brss;
  final double tauxSecu;
  final double remboursementSecu;
  final double remboursementMutuelle;
  final double participationForfaitaire;
  final double totalAutoriseMutuelle;
  final double totalRembourse;
  final double resteACharge;
  final double montantDepassement;
  final bool estConventionne;
  final DateTime createdAt;

  SimulationHistory({
    required this.id,
    required this.soinName,
    this.soinIcon,
    this.categorieName,
    required this.prixFacture,
    required this.brss,
    required this.tauxSecu,
    required this.remboursementSecu,
    required this.remboursementMutuelle,
    required this.participationForfaitaire,
    required this.totalAutoriseMutuelle,
    required this.totalRembourse,
    required this.resteACharge,
    required this.montantDepassement,
    required this.estConventionne,
    required this.createdAt,
  });

  factory SimulationHistory.fromJson(Map<String, dynamic> json) {
    return SimulationHistory(
      id: json['id'] as int,
      soinName: json['soin_name'] as String,
      soinIcon: json['soin_icon'] as String?,
      categorieName: json['categorie_name'] as String?,
      prixFacture: (json['prix_facture'] as num).toDouble(),
      brss: (json['brss'] as num).toDouble(),
      tauxSecu: (json['taux_secu'] as num).toDouble(),
      remboursementSecu: (json['remboursement_secu'] as num).toDouble(),
      remboursementMutuelle: (json['remboursement_mutuelle'] as num).toDouble(),
      participationForfaitaire: (json['participation_forfaitaire'] as num).toDouble(),
      totalAutoriseMutuelle: (json['total_autorise_mutuelle'] as num).toDouble(),
      totalRembourse: (json['total_rembourse'] as num).toDouble(),
      resteACharge: (json['reste_a_charge'] as num).toDouble(),
      montantDepassement: (json['montant_depassement'] as num).toDouble(),
      estConventionne: json['est_conventionne'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  double get pourcentagePriseEnCharge {
    if (resteACharge == 0) return 100.0;
    return (totalRembourse / (resteACharge + totalRembourse)) * 100;
  }
}
